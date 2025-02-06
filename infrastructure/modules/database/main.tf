resource "aws_dynamodb_table" "url_shortener_table" {
  name = "url_shortener_table-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "short_url"

  attribute {
    name = "short_url"
    type = "S"
  }

  attribute {
    name = "long_url"
    type = "S"
  }

  ttl {
    attribute_name = "expiration_time"
    enabled = true
  }
}