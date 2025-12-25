terraform {
  backend "s3" {
    bucket         = "autoops-terraform-state-605134452604"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
