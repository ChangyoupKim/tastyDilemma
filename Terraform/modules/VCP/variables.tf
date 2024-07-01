# Local Variable 정의
locals {
  cidr             = "10.10.0.0/16"
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets   = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets  = ["10.10.10.0/24", "10.10.30.0/24"]
  database_subnets = ["10.10.20.0/24", "10.10.40.0/24"]
  ssh_port         = 22
  http_port        = 80
  https_port       = 443
  db_port          = 3306
  any_port         = 0
  any_protocol     = "-1"
  tcp_protocol     = "tcp"
  all_network      = "0.0.0.0/0"
}



// VPC에서 사용 할 입력변수를 정의
variable "vpc_cidr" {
  description = "VPC CIDR BLOCK"
  type        = string
}

variable "public-1_cidr" {
  description = "public-1 CIDR BLOCK"
  type        = string
}

variable "public-2_cidr" {
  description = "public-2 CIDR BLOCK"
  type        = string
}

variable "private-1_cidr" {
  description = "Private-1 CIDR BLOCK"
  type        = string
}

variable "private-2_cidr" {
  description = "Private-2 CIDR BLOCK"
  type        = string
}

variable "private-3_cidr" {
  description = "Private-3 CIDR BLOCK"
  type        = string
}

variable "private-4_cidr" {
  description = "Private-4 CIDR BLOCK"
  type        = string
}

variable "db-subnet-1_cidr" {
  description = "DB-Subnet-1 CIDR BLOCK"
  type        = string
}

variable "db-subnet-2_cidr" {
  description = "DB-Subnet-2 CIDR BLOCK"
  type        = string
}

variable "ssh_port" {
  description = "The Port the Server Will use for SSH Service"
  type        = number
}