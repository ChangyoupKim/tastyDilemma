terraform {
  backend "s3" {
    bucket  = "tastydilemma-terraform-state"
    key     = "stage/Application/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "terraform_user"
    dynamodb_table = "myTerraform-bucket-lock-changyoup"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform_user"
}
