data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../app"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "autoops" {
  function_name = "autoops-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_handler.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
}
