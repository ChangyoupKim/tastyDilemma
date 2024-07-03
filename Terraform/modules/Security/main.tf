terraform {
  backend "s3" {
    bucket  = "tastydilemma-terraform-state"
    key     = "${var.name}/Security/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "terraform_user"
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



######################################################################
#                           Security Group                           #
######################################################################

# SSH SG
module "SSH_SG" {
  source          = "github.com/ChangyoupKim/Terraform_Project_SG"
  name            = "SSH_SG"
  description     = "SSH Port Allow"
  vpc_id          = module.stage_vpc.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.ssh_port
      to_port     = local.ssh_port
      protocol    = local.tcp_protocol
      description = "SSH Port Allow"
      cidr_blocks = local.all_network
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}


# HTTP HTTPS SG
module "HTTP_HTTPS_SG" {
  source          = "github.com/ChangyoupKim/Terraform_Project_SG"
  name            = "HTTP_HTTPS_SG"
  description     = "HTTP, HTTPS Port Allow"
  vpc_id          = module.stage_vpc.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.http_port
      to_port     = local.http_port
      protocol    = local.tcp_protocol
      description = "HTTP Port Allow"
      cidr_blocks = local.all_network
    },
    {
      from_port   = local.https_port
      to_port     = local.https_port
      protocol    = local.tcp_protocol
      description = "HTTPS Port Allow"
      cidr_blocks = local.all_network
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}


# RDS SG
module "RDS_SG" {
  source          = "github.com/ChangyoupKim/Terraform_Project_SG"
  name            = "RDS_SG"
  description     = "DB Port Allow"
  vpc_id          = module.stage_vpc.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = local.private_subnets[0]
    },
    {
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = local.private_subnets[1]
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}
