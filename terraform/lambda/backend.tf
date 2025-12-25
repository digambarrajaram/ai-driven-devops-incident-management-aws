terraform {
  backend "s3" {
    bucket         = "autoops-terraform-state-<AWS Account ID>"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
