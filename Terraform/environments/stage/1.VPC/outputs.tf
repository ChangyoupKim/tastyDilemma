// OutPut 정의
// EC2 인스턴스에 EIP를 부여했으므로, EIP에 부여 된 Public IP주소를 출력하도록 한다.
output "EC2_Pub_IPs" {
  value       = { for k, v in aws_eip.BastionHost : k => v.public_ip }
  description = "EC2 Instances Public IP Addresses"
}

output "vpc_id" {
  value       = module.stage_vpc.vpc_id
  description = "VPC ID Output"
}

output "public_subnets" {
  value       = module.stage_vpc.public_subnets
  description = "Public_Subnets Output"
}

output "private_subnets" {
  value       = module.stage_vpc.private_subnets
  description = "Private_Subnets Output"
}

output "database_subnets" {
  value       = module.stage_vpc.database_subnets
  description = "Database_Subnets Output"
}

output "database_subnet_group" {
  value       = module.stage_vpc.database_subnet_group
  description = "Database_Subnet_Group Output"
}

output "SSH_SG" {
  value       = module.SSH_SG.security_group_id
  description = "SSH Security-Group Output"
}

output "HTTP_HTTPS_SG" {
  value       = module.HTTP_HTTPS_SG.security_group_id
  description = "HTTP_HTTPS Security-Group Output"
}
