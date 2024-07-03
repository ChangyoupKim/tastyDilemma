
data "terraform_remote_state" "vpc_remote_data" {
  backend = "s3"
  config = {
    bucket  = "tastydilemma-terraform-state"
    key     = "stage/vpc/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}

data "terraform_remote_state" "alb_remote_data" {
  backend = "s3"
  config = {
    bucket  = "tastydilemma-terraform-state"
    key     = "stage/alb/terraform.tfstate" # (Update)
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}

data "terraform_remote_state" "rds_remote_data" {
  backend = "s3"
  config = {
    bucket  = "tastydilemma-terraform-state"
    key     = "stage/rds/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}