import json
import re
import time
import uuid
import boto3
import os
import logging

# Set up logging
logger = logging.getLogger()

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

# Expiration time: 1 day from now (in seconds)
EXPIRATION_TIME_DURATION = 1 * 24 * 60 * 60

def is_valid_url(url):
    regex = r'^(https?|ftp)://[^\s/$.?#].[^\s]*$'
    return re.match(regex, url) is not None

def shorten_url(event, context):
    try:
        body = json.loads(event['body'])
        long_url = body.get("long_url")

        if not long_url:
            logger.error("long_url is missing from the request body.")
            return {"statusCode": 400, "body": json.dumps({"error": "long_url is required"})}

        if not is_valid_url(long_url):
            logger.error(f"Invalid long_url format: {long_url}")
            return {"statusCode": 400, "body": json.dumps({"error": "Invalid URL format."})}

        short_url = str(uuid.uuid4())[:8]
        expiration_time = int(time.time()) + EXPIRATION_TIME_DURATION

        table.put_item(Item={
            "short_url": short_url,
            "long_url": long_url,
            "expiration_time": expiration_time
        })

        logger.info(f"Successfully created short URL {short_url} for long URL {long_url}")
        return {
            "statusCode": 200,
            "body": json.dumps({"short_url": short_url, "expires_at": expiration_time})
        }

    except Exception as e:
        logger.error(f"Error occurred while shortening URL: {str(e)}")
        return {"statusCode": 500, "body": json.dumps({"error": "Internal server error"})}


def get_long_url(event, context):
    short_url = event['pathParameters']['short_url']

    try:
        if not short_url:
            logger.error("short_url is missing in the path parameters.")
            return {"statusCode": 400, "body": json.dumps({"error": "short_url is required"})}

        response = table.get_item(Key={"short_url": short_url})
        item = response.get('Item')

        if not item:
            logger.warning(f"Short URL {short_url} not found in DynamoDB.")
            return {"statusCode": 404, "body": json.dumps({"error": "Short URL not found"})}

        logger.info(f"Redirecting to long URL {item['long_url']} for short URL {short_url}")
        return {
            "statusCode": 302,
            "headers": {"Location": item["long_url"]},
            "body": json.dumps({"long_url": item["long_url"]})
        }

    except Exception as e:
        logger.error(f"Error occurred while retrieving long URL for {short_url}: {str(e)}")
        return {"statusCode": 500, "body": json.dumps({"error": "Internal server error"})}