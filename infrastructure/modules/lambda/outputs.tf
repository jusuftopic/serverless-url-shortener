output "shorten_url_lambda_invoke_arn" {
  value = aws_lambda_function.shorten_url_lambda.invoke_arn
}

output "long_url_lambda_invoke_arn" {
  value = aws_lambda_function.long_url_lambda.invoke_arn
}

output "shorten_url_lambda_function_name" {
  value = aws_lambda_function.shorten_url_lambda.function_name
}

output "long_url_lambda_function_name" {
  value = aws_lambda_function.long_url_lambda.function_name
}
