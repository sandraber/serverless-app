terraform {
  backend "s3" {
    bucket  = "backend-terraform-serverless-app"
    key     = "serverles-app/terraform.tfstate"
    region  = "eu-west-1"
    profile = "terraform"
  }
}