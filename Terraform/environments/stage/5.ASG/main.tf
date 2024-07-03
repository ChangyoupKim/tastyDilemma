terraform {
  backend "s3" {
    bucket         = "tastydilemma-terraform-state"
    key            = "stage/asg/terraform.tfstate"
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
#                          ASG 생성                           #
###############################################################
module "stage_asg" {
  source            = "../../../modules/asg"
  instance_type     = "t2.micro"
  desired_capacity  = "2"
  min_size          = "2"
  max_size          = "4"
  name              = "stage"
  private_subnets   = data.terraform_remote_state.vpc_remote_data.outputs.private_subnets
  SSH_SG_ID         = data.terraform_remote_state.vpc_remote_data.outputs.SSH_SG
  HTTP_HTTPS_SG_ID  = data.terraform_remote_state.vpc_remote_data.outputs.HTTP_HTTPS_SG
  key_name          = "EC2-key"
  target_group_arns = [data.terraform_remote_state.alb_remote_data.outputs.ALB_TG]
}
