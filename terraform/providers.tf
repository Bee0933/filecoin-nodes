# provider
terraform {

  # backend "s3" {
  #   bucket         = "cc-tf-state-backend-ci-cd"
  #   key            = "tf-infra/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

# module "tf-state" {
#   source      = "./modules/tf-state"
#   bucket_name = "cc-tf-state-backend-ci-cd"
# }