resource "aws_cloudwatch_log_group" "autoops" {
  name              = "/aws/apprunner/autoops-web"
  retention_in_days = 7
}
