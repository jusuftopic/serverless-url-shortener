# REST API
resource "aws_api_gateway_rest_api" "url_shortener_api" {
  name = "UrlShortenerAPI"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# USAGE PLAN
resource "aws_api_gateway_usage_plan" "shortener_usage_plan" {
  name        = "url-shortener-usage-plan-${var.environment}"
  description = "Throttling limits for URL Shortener API"

  throttle_settings {
    rate_limit  = 10    # Max 10 requests per second
    burst_limit = 20    # Allow up to 20 requests concurrent
  }

  api_stages {
    api_id = aws_api_gateway_rest_api.url_shortener_api.id
    stage  = aws_api_gateway_stage.url_shortener_stage.stage_name
  }
}

# RESOURCE FOR SHORTENING URL
resource "aws_api_gateway_resource" "url_shortener_api_resource" {
  parent_id   = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  path_part   = "url-shortener"
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
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri = var.long_url_lambda_invoke_arn

  request_parameters = {
    "integration.request.path.short_url" = "method.request.path.short_url"
  }
}

# url-shortener CORS
resource "aws_api_gateway_method" "url_shortener_cors" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.url_shortener_api_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

# url-shortener CORS INTEGRATION
resource "aws_api_gateway_integration" "url_shortener_cors_integration" {
  http_method = aws_api_gateway_method.url_shortener_cors.http_method
  resource_id = aws_api_gateway_resource.url_shortener_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  type        = "MOCK"


  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

# url-shortener CORS METHOD RESPONSE
resource "aws_api_gateway_method_response" "url_shortener_cors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.url_shortener_api_resource.id
  http_method = aws_api_gateway_method.url_shortener_cors.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# url-shortener CORS INTEGRATION RESPONSE
resource "aws_api_gateway_integration_response" "url_shortener_cors_integration_response" {
  http_method = aws_api_gateway_method.url_shortener_cors.http_method
  resource_id = aws_api_gateway_resource.url_shortener_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  status_code = aws_api_gateway_method_response.url_shortener_cors_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST,GET'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# long_url CORS
resource "aws_api_gateway_method" "long_url_cors" {
  authorization = "NONE"
  http_method   = "OPTIONS"
  resource_id   = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
}

# long_url CORS INTEGRATION
resource "aws_api_gateway_integration" "long_url_cors_integration" {
  http_method = aws_api_gateway_method.long_url_cors.http_method
  resource_id = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

# long_url CORS METHOD RESPONSE
resource "aws_api_gateway_method_response" "long_url_cors_method_response" {
  http_method = aws_api_gateway_method.long_url_cors.http_method
  resource_id = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# long_url CORS INTEGRATION RESPONSE
resource "aws_api_gateway_integration_response" "long_url_integration_cors_response" {
  http_method = aws_api_gateway_method.long_url_cors.http_method
  resource_id = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  status_code = aws_api_gateway_method_response.long_url_cors_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST,GET'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  response_templates = {
    "application/json" = ""
  }
}

# shorten_url METHOD RESPONSE
resource "aws_api_gateway_method_response" "url_shorten_method_response" {
  http_method = aws_api_gateway_method.shorten_url.http_method
  resource_id = aws_api_gateway_resource.url_shortener_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}


# long_url METHOD RESPONSE
resource "aws_api_gateway_method_response" "long_url_method_response" {
  http_method = aws_api_gateway_method.get_long_url.http_method
  resource_id = aws_api_gateway_resource.long_url_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# DEPLOY API GATEWAY
resource "aws_api_gateway_deployment" "url_shortener_deployment" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id

  depends_on = [
    aws_api_gateway_integration.shorten_url_lambda,
    aws_api_gateway_integration.get_long_url_lambda,
    aws_api_gateway_integration.url_shortener_cors_integration,
    aws_api_gateway_integration.long_url_cors_integration
  ]
}

# API GATEWAY STAGE SETTINGS
resource "aws_api_gateway_stage" "url_shortener_stage" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  stage_name    = var.environment
  deployment_id = aws_api_gateway_deployment.url_shortener_deployment.id
}

# API Gateway Permissions for Lambda
resource "aws_lambda_permission" "apigw_shorten_url" {
  statement_id  = "AllowAPIGatewayInvokeShorten"
  action        = "lambda:InvokeFunction"
  function_name = var.shorten_url_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_shortener_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get_long_url" {
  statement_id  = "AllowAPIGatewayInvokeGetLong"
  action        = "lambda:InvokeFunction"
  function_name = var.long_url_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.url_shortener_api.execution_arn}/*/*"
}
