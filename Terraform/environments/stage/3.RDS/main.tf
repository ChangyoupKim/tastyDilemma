terraform {
  backend "s3" {
    bucket         = "tastydilemma-terraform-state"
    key            = "stage/rds/terraform.tfstate"
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
#                          RDS 생성                           #
###############################################################

# DataSource 정의
module "tastydilemma-db" {
  source                              = "github.com/ChangyoupKim/Terraform_Project_RDS"
  identifier                          = "tastydilemma" # 식별이름 : 알파벳 소문자, 하이픈만 사용가능
  engine                              = "mysql"
  engine_version                      = "5.7"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 5
  multi_az                            = false      # 선택사항 (사용 : true)
  iam_database_authentication_enabled = true       # IAM 계정 RDS 인증 사용
  manage_master_user_password         = false      # SecretManager: True(기본값) / Password:false
  skip_final_snapshot                 = true       # RDS Instance 삭제 시 Snapshot 생성여부 결정
  family                              = "mysql5.7" # DB parameter group (Required Option)
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  major_engine_version = "5.7" # DB option group (Required Option) Engine마다 지원하는 옵션이 다르다. 
  db_name              = "webdb"
  username             = "admin"
  password             = "RDSterraform123!" # Env or Secret Manager 사용권장!
  port                 = "3306"
  # DB subnet group & DB Security-Group
  db_subnet_group_name   = data.terraform_remote_state.vpc_remote_data.outputs.database_subnet_group
  subnet_ids             = data.terraform_remote_state.vpc_remote_data.outputs.database_subnets
  vpc_security_group_ids = [data.terraform_remote_state.sg_remote_data.outputs.RDS_SG]
}
