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