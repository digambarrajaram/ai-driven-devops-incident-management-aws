resource "aws_ecr_repository" "autoops" {
  name                 = "autoops-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
