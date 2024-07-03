terraform {
  backend "s3" {
    bucket         = "tastydilemma-terraform-state"
    key            = "stage/alb/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "tastydilemma-terraform-state-lock"
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



###############################################################
#                          ALB 생성                           #
###############################################################
module "stage_alb" {
  source           = "../../../modules/alb"
  name             = "stage"
  vpc_id           = data.terraform_remote_state.vpc_remote_data.outputs.vpc_id
  public_subnets   = data.terraform_remote_state.vpc_remote_data.outputs.public_subnets
  HTTP_HTTPS_SG_ID = data.terraform_remote_state.vpc_remote_data.outputs.HTTP_HTTPS_SG
}
