terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
resource "aws_s3_bucket" "angular_app" {
  bucket = "url-shortener-ui-${var.environment}"
}

resource "aws_s3_bucket_website_configuration" "angular_app_hosting" {
  bucket = aws_s3_bucket.angular_app.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.angular_app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.angular_app.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.angular_app.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}