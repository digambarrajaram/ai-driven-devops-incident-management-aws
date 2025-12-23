resource "aws_cloudwatch_log_group" "autoops_logs" {
  name              = "/aws/apprunner/autoops-web"
  retention_in_days = 7
}
