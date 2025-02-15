terraform {
  backend "s3" {
    bucket = "url-shortener-terraform-state-remote"
    key = "url-shortener-terraform-state-remote/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "shortener_terraform_state_locks"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "shortener_terraform_state" {
  bucket = "url-shortener-terraform-state-remote"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "shortener_terraform_state_versioning" {
  bucket = aws_s3_bucket.shortener_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shortener_terraform_state_encryption" {
  bucket = aws_s3_bucket.shortener_terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "shortener_terraform_state_locks" {
  name = "shortener_terraform_state_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}