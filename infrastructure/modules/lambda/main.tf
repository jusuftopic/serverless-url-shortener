
# LAMBDA IAM ROLE FOR DYNAMO DB ACCESS
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role_${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# DYNAMO DB ACCESS POLICY
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_policy_${var.environment}"
  description = "Policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem"]
        Effect   = "Allow"
        Resource = var.url_shortener_table_arn
      },
    ]
  })
}

# LAMBDA ROLE POLICY ATTACHMENT
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# LAMBDA FUNCTIONS ARCHIVE FILE
data "archive_file" "url_shortener_lambda_zip" {
  source_dir = "${path.module}/../../../backend"
  output_path = "url_shortener_lambda.zip"
  type        = "zip"
}

# LAMBDA FUNCTION "shorten_url"
resource "aws_lambda_function" "shorten_url_lambda" {
  function_name = "shorten_url_lambda_${var.environment}"
  filename = "url_shortener_lambda.zip"
  source_code_hash = data.archive_file.url_shortener_lambda_zip.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = var.lambda_runtime
  handler = "main.shorten_url"
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      DYNAMODB_TABLE = var.url_shortener_table_name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

resource "aws_lambda_function" "long_url_lambda" {
  function_name = "get_long_url_lambda_${var.environment}"
  filename = "url_shortener_lambda.zip"
  source_code_hash = data.archive_file.url_shortener_lambda_zip.output_base64sha256
  role          = aws_iam_role.lambda_role.arn
  runtime       = var.lambda_runtime
  handler = "main.get_long_url"
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      DYNAMODB_TABLE = var.url_shortener_table_name
    }
  }

    depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

# ENABLE LOGGING FOR LAMBDA FUNCTIONS
resource "aws_cloudwatch_log_group" "shorten_url_lambda_log_group" {
  name              = "/aws/lambda/shorten_url_lambda_${var.environment}"
  retention_in_days = 1
}

#add IAM policy for CloudWatch logs
resource "aws_iam_policy" "lambda_cloudwatch_policy" {
  name        = "lambda_cloudwatch_policy_${var.environment}"
  description = "Policy for Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.shorten_url_lambda_log_group.arn}:*"
      },
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_policy.arn
}