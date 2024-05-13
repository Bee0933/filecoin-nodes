# provider
terraform {

  backend "s3" {
    bucket         = "filecoin-tf-state-backend"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

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
#   bucket_name = "filecoin-tf-state-backend"
# }