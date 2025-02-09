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

variable "url_shortener_api_execution_arn" {
  description = "URL shortener REST API execution ARN"
  type = string
}