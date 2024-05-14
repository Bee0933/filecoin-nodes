terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "tf-state" {
  source      = "../modules/tf-state"
  bucket_name = "filecoin-tf-state-backend"
}