data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "policy_lambda_s3" {
  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    sid    = "S3Read"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "${aws_s3_bucket.serverless-app.arn}",
      "${aws_s3_bucket.serverless-app.arn}/*"
    ]
  }


  statement {
    sid    = "S3ReadWrite"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:AbortMultipartUpload",
      "s3:CreateBucket",
      "s3:DeleteObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.serverless-app.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_s3" {
  name        = "policy_lambda_s3"
  description = "Policy with permissions to lambda"
  policy      = data.aws_iam_policy_document.policy_lambda_s3.json
}
resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}