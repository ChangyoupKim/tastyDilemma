variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}

variable "min_size" {
  description = "ASG Min Size"
  type        = string
}

variable "max_size" {
  description = "ASG Max Size"
  type        = string
}

variable "name" {
  description = "ENV Name(Stage or Prod)"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets for the ASG"
  type        = list(string)
}

variable "SSH_SG_ID" {
  description = "Security Group ID for SSH access"
  type        = string
}

variable "HTTP_HTTPS_SG_ID" {
  description = "Security Group ID for HTTP/HTTPS access"
  type        = string
}

variable "target_group_arns" {
  description = "A list of target group ARNs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "The desired number of instances"
  type        = number
}

variable "key_name" {
  description = "The name of the key pair"
  type        = string
}
