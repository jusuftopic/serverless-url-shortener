variable "shorten_url_lambda_invoke_arn" {
  description = "Shorten URL lambda function invoke arn"
  type = string
}

variable "long_url_lambda_invoke_arn" {
  description = "Retrieve long URL lambda function invoke arn"
  type = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev)"
  type = string
  default = "prod"
}

variable "shorten_url_lambda_function_name" {
  description = "Lambda function name for handling shorten url"
  type = string
}

variable "long_url_lambda_function_name" {
  description = "Lambda function name for handling shorten url"
  type = string
}