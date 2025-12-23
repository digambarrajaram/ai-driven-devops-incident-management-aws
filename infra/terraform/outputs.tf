output "ecr_repository_url" {
  value = aws_ecr_repository.autoops.repository_url
}

output "apprunner_service_url" {
  value = aws_apprunner_service.autoops.service_url
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}