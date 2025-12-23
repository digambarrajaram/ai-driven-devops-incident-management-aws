output "ecr_repository_url" {
  value = aws_ecr_repository.autoops.repository_url
}

output "apprunner_service_url" {
  value = aws_apprunner_service.autoops.service_url
}