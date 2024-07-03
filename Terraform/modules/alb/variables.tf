variable "name" {
  description = "ENV Name(Stage or Prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC_ID"
  type        = string
}

variable "HTTP_HTTPS_SG_ID" {
  description = "HTTP_HTTPS_SG_ID"
  type        = string
}

variable "public_subnets" {
  description = "Public_Subnets"
  type        = list(string)
}
