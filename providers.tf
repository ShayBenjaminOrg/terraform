# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 3.20.0"
#     }
#   }
# }

# provider "aws" {
#   region                  = var.region
#   shared_credentials_file = "%HOMEPATH%/.aws/credentials"
#   profile                 = "default"
# }


terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}