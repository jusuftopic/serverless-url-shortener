output "url_shortener_website_url" {
  value = "https://${aws_cloudfront_distribution.angular_cdn.domain_name}"
}