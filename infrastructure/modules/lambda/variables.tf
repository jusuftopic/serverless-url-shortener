variable "environment" {
  description = "Environment (e.g., prod, dev)"
  type = string
  default = "prod"
}

variable "url_shortener_table_name" {
  description = "DynamoDB table for storing url-shortener data"
  type = string
}

variable "url_shortener_table_arn" {
  description = "DynamoDB table ARN"
  type = string
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 15
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}