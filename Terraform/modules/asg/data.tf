data "terraform_remote_state" "vpc_remote_data" {
  backend = "s3"
  config = {
    bucket  = "tastydilemma-terraform-state"
    key     = "${var.name}/vpc/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}

data "terraform_remote_state" "alb_remote_data" {
  backend = "s3"
  config = {
    bucket  = "tastydilemma-terraform-state"
    key     = "${var.name}/alb/terraform.tfstate" # (Update)
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}

data "terraform_remote_state" "rds_remote_data" {
  backend = "s3"
  config = {
    bucket  = "tastydilemma-terraform-state"
    key     = "${var.name}/rds/terraform.tfstate"
    profile = "terraform_user"
    region  = "ap-northeast-2"
  }
}
