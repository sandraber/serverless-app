provider "aws" {
  region              = var.region
  profile             = "terraform"
  allowed_account_ids = ["891377179943"]

  default_tags {
    tags = {
      Role        = var.project_name
      Provisioner = "Terraform"
    }
  }
}