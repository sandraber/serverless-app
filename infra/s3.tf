resource "aws_s3_bucket" "serverless-app" {
  bucket = "${var.project_name}-lambda"
}

resource "aws_s3_bucket_public_access_block" "serverless-app" {
  bucket = aws_s3_bucket.serverless-app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "serverless-app" {
  bucket = aws_s3_bucket.serverless-app.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "serverless-app" {
  bucket = aws_s3_bucket.serverless-app.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Remove ACLs and rely only on IAM policies
resource "aws_s3_bucket_ownership_controls" "serverless-app" {
  bucket = aws_s3_bucket.serverless-app.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "serverless-app" {
  bucket = aws_s3_bucket.serverless-app.id
  policy = data.aws_iam_policy_document.combined.json
}
