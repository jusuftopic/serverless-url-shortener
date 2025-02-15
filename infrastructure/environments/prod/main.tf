provider "aws" {
  region = "eu-central-1"
}

# STORAGE
module "database" {
  source = "../../modules/database"

  environment = var.environment
}

# LAMBDA FUNCTIONS
module "lambda" {
  source = "../../modules/lambda"

  environment = var.environment
  url_shortener_table_name = module.database.url_shortener_table_name
  url_shortener_table_arn = module.database.url_shortener_table_arn
}

# API GATEWAY
module "api_gateway" {
  source = "../../modules/gateway"

  environment = var.environment

  long_url_lambda_function_name = module.lambda.long_url_lambda_function_name
  long_url_lambda_invoke_arn = module.lambda.long_url_lambda_invoke_arn

  shorten_url_lambda_function_name = module.lambda.shorten_url_lambda_function_name
  shorten_url_lambda_invoke_arn = module.lambda.shorten_url_lambda_invoke_arn
}

# S3 UI HOSTING + CLOUDFRONT
module "s3" {
  source = "../../modules/s3"

  environment = var.environment
}