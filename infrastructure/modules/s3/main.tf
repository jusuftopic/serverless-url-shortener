# BUCKET
resource "aws_s3_bucket" "angular_app" {
  bucket = "url-shortener-ui-${var.environment}"
}

# HOSTING SETTINGS
resource "aws_s3_bucket_website_configuration" "angular_app_hosting" {
  bucket = aws_s3_bucket.angular_app.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

# CLOUDFRONT OAC
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "url-shortener-ui-${var.environment}-oac"
  description                       = "OAC for accessing S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CLOUDFRONT DISTRIBUTION
resource "aws_cloudfront_distribution" "angular_cdn" {
  origin {
    domain_name              = aws_s3_bucket.angular_app.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.angular_app.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled = true
  default_root_object = "index.html"

  # Caching behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.angular_app.id}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Use a free CloudFront SSL certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # No geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# BUCKET POLICY
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.angular_app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.angular_app.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.angular_cdn.arn
          }
        }
      }
    ]
  })
}

# OWNERSHIP CONTROL
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.angular_app.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}