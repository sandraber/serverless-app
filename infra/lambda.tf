data "archive_file" "serverles-app" {
  type = "zip"

  source {
    content  = file("${path.module}/${var.project_name}.py")
    filename = "${var.project_name}.py"
  }

  output_path = "./${var.project_name}.zip"
}

resource "aws_lambda_function" "process_text" {
  filename         = "./${var.project_name}.zip"
  function_name    = "process_text"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "${var.project_name}.lambda_handler"
  source_code_hash = data.archive_file.serverles-app.output_base64sha256
  runtime          = "python3.8"
  timeout          = 300
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.serverless-app.bucket
    }
  }
}
