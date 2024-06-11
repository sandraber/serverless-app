# Amazon allows both HTTP and HTTPS requests. This policy
# denies access to any HTTP request. Only TLS connections are
# accepted.
data "aws_iam_policy_document" "force_ssl_only_access" {

  statement {
    sid    = "ForceSSLOnlyAccess"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.serverless-app.arn,
      "${aws_s3_bucket.serverless-app.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

# Amazon allows every TLS version. This policy allows only
# TLS1.2 or higher for all connections to the bucket
data "aws_iam_policy_document" "require_latest_tls_version" {

  statement {
    sid    = "RequireLatestTLSVersion"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.serverless-app.arn,
      "${aws_s3_bucket.serverless-app.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

# AWS allows uploading unencrypted objects to an encrypted bucket.
# This policy ensures every object updated to the bucket is encrypted
data "aws_iam_policy_document" "allow_encrypted_uploads_only" {

  statement {
    sid       = "AllowEncryptedUploadsOnly"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.serverless-app.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      values   = ["true"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.allow_encrypted_uploads_only.json,
    data.aws_iam_policy_document.force_ssl_only_access.json,
    data.aws_iam_policy_document.require_latest_tls_version.json,
  ])
}

data "aws_caller_identity" "current" {
}
