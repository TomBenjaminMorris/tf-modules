############ S3 bucket for website ############

data "template_file" "www_bucket_policy" {
  template = file("${path.module}/templates/s3-policy.json")
  vars = {
    bucket = aws_s3_bucket.www_bucket.arn
    dist   = aws_cloudfront_distribution.www_s3_distribution.arn
  }
}

resource "aws_s3_bucket_policy" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.template_file.www_bucket_policy.rendered
}

resource "aws_s3_bucket_cors_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}", "https://${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_public_access_block" "www_bucket_public_block" {
  bucket                  = aws_s3_bucket.www_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "www_bucket" {
  #checkov:skip=CKV2_AWS_62:No need for S3 notifications
  #checkov:skip=CKV2_AWS_61:No need for S3 lifecycles
  #checkov:skip=CKV_AWS_144:No need for S3 cross-region replication
  #checkov:skip=CKV_AWS_21:No need for S3 versioning
  #checkov:skip=CKV_AWS_145:No need for S3 KMS encryption
  #checkov:skip=CKV_AWS_18:No need for S3 access logging
  bucket = "www.${var.domain_name}"
  tags   = var.common_tags
}

############ S3 bucket for redirecting non-www to www ############

resource "aws_s3_bucket_public_access_block" "root_bucket_public_block" {
  bucket                  = aws_s3_bucket.root_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "root_bucket" {
  bucket = aws_s3_bucket.root_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "root_bucket" {
  #checkov:skip=CKV2_AWS_62:No need for S3 notifications
  #checkov:skip=CKV2_AWS_61:No need for S3 lifecycles
  #checkov:skip=CKV_AWS_144:No need for S3 cross-region replication
  #checkov:skip=CKV_AWS_21:No need for S3 versioning
  #checkov:skip=CKV_AWS_145:No need for S3 KMS encryption
  #checkov:skip=CKV_AWS_18:No need for S3 access logging
  bucket = var.domain_name
  website {
    redirect_all_requests_to = "https://www.${var.domain_name}"
  }
  tags = var.common_tags
}