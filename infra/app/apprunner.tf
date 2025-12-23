resource "aws_apprunner_service" "autoops" {
  service_name = "autoops-web-app"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }

    image_repository {
      image_repository_type = "ECR"
      image_identifier      = "${aws_ecr_repository.autoops.repository_url}:initial"

      image_configuration {
        port = "8080"
      }
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }
}
