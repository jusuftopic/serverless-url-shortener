terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
# REST API
resource "aws_api_gateway_rest_api" "url_shortener_api" {
  name = "UrlShortenerAPI"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# RESOURCE FOR SHORTENING URL
resource "aws_api_gateway_resource" "url_shortener_api_resource" {
  parent_id   = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  path_part   = "url-shortener"
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
}

# RESOURCE FOR RETRIEVING long URL
resource "aws_api_gateway_resource" "long_url_api_resource" {
  parent_id   = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  path_part   = "{short_url}"
}

# REST API shorten_url METHOD
resource "aws_api_gateway_method" "shorten_url" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.url_shortener_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
}

# REST API get_long_url METHOD
resource "aws_api_gateway_method" "get_long_url" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id

  request_parameters = {
    "method.request.path.short_url" = true
  }
}

# INTEGRATION FOR shorten URL Lambda
resource "aws_api_gateway_integration" "shorten_url_lambda" {
  resource_id = aws_api_gateway_resource.url_shortener_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  http_method = aws_api_gateway_method.shorten_url.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri = var.shorten_url_lambda_invoke_arn
}

# INTEGRATION FOR long URL retrieve Lambda
resource "aws_api_gateway_integration" "get_long_url_lambda" {
  resource_id = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  http_method = aws_api_gateway_method.get_long_url.http_method
  integration_http_method = "GET"
  type        = "AWS_PROXY"
  uri = var.long_url_lambda_invoke_arn
}

# DEPLOY API GATEWAY
resource "aws_api_gateway_deployment" "url_shortener_deployment" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id

  depends_on = [
  aws_api_gateway_integration.shorten_url_lambda,
  aws_api_gateway_integration.get_long_url_lambda
  ]
}

# API GATEWAY STAGE SETTINGS
resource "aws_api_gateway_stage" "url_shortener_stage" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  stage_name    = var.environment
  deployment_id = aws_api_gateway_deployment.url_shortener_deployment.id
}
