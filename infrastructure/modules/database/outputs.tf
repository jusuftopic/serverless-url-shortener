output "url_shortener_table_arn" {
  value = aws_dynamodb_table.url_shortener_table.arn
}

output "url_shortener_table_name" {
  value = aws_dynamodb_table.url_shortener_table.name
}