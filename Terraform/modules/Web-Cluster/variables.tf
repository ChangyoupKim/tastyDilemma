// ASG에서 사용 할 입력변수를 정의 
variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
}
# Instance Type

variable "min_size" {
  description = "ASG Min Size"
  type        = string
}
# Instance 최소 용량

variable "max_size" {
  description = "ASG Max Size"
  type        = string
}
# Instance 최대 용량

variable "http_port" {
  description = "The Port the Server Will use for HTTP Service"
  type        = number
}
# Instance에서 허용 할 Port (HTTP : TCP/80)

variable "vpc_id" {
  description = "VPC Module ID"
  type        = string
}

variable "public_subnet1" {
  description = "public-1 ID"
  type        = string
}

variable "public_subnet2" {
  description = "public-2 ID"
  type        = string
}

variable "private_subnet1" {
  description = "Private-1 ID"
  type        = string
}

variable "private_subnet2" {
  description = "Private-2 ID"
  type        = string
}