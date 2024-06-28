// OutPut 정의
// EC2 인스턴스에 EIP를 부여했으므로, EIP에 부여 된 Public IP주소를 출력하도록 한다.
output "EC2_Pub_IP-1" {
  value       = aws_eip.BastionHost-1_eip.public_ip
  description = "EC2 Instance Public IP Address"
}

output "EC2_Pub_IP-2" {
  value       = aws_eip.BastionHost-2_eip.public_ip
  description = "EC2 Instance Public IP Address"
}

# ※ Terraform_remote_state를 사용하기위해 VPC Module의 Output 영역을 추가로 정의한다.
// VPC Module의 Output 영역을 추가로 정의한다.
output "vpc_id" {
  value       = aws_vpc.td-vpc-01.id
  description = "VPC Module ID"
}

output "public_subnet1" {
  value       = aws_subnet.Public-subnet-01.id
  description = "public_subnet1"
}

output "public_subnet2" {
  value       = aws_subnet.Public-subnet-02.id
  description = "public_subnet2"
}

output "private_subnet1" {
  value       = aws_subnet.Private-subnet-01.id
  description = "private_subnet1"
}

output "private_subnet2" {
  value       = aws_subnet.Private-subnet-02.id
  description = "private_subnet2"
}

output "db_subnet1" {
  value       = aws_subnet.DB-subnet-01.id
  description = "db_subnet1"
}
  
output "db_subnet2" {
  value       = aws_subnet.DB-subnet-02.id
  description = "db_subnet2"
}