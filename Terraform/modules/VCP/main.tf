terraform {
  backend "s3" {
    bucket  = "tastydilemma-terraform-state"
    key     = "${var.name}/VCP/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "terraform_user"
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



######################################################################
#                                VPC                                 #
######################################################################

# Stage VPC
module "stage_vpc" {
  source = "github.com/ChangyoupKim/Terraform_Project_VPC"
  name   = "stage_vpc"
  cidr   = local.cidr

  azs              = local.azs
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    "TerraformManaged" = "true"
  }
}


// VPC 정의 영역 ( DNS Hostnames, DNS support 기능 활성화 )
resource "aws_vpc" "td-vpc-01" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true      // VPC 내부에 생성되는 리소스의 호스트 이름부여 기능
  enable_dns_hostnames = true      // VPC 내부 DNS 지원여부
  instance_tenancy     = "default" // 전용으로 설정 할 경우 해당 VPC에서 EC2 인스턴스 생성 시 전용 하드웨어를 사용

  tags = {
    Name = "terraform-vpc-01"
  }
}


// public subnets 정의 영역
resource "aws_subnet" "Public-subnet-01" {
  vpc_id                  = aws_vpc.td-vpc-01.id // 위에서 생성 된 VPC의 ID값을 참조      
  cidr_block              = var.public-1_cidr // 생성되는 Subnet의 CIDR Block
  map_public_ip_on_launch = true              // Public IP주소 자동 할당
  availability_zone       = "ap-northeast-2a" // 가용영역
  tags = {
    Name = "terraform-public-1"
  }
}

resource "aws_subnet" "Public-subnet-02" {
  vpc_id                  = aws_vpc.td-vpc-01.id
  cidr_block              = var.public-2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  tags = {
    Name = "terraform-public-2"
  }
}


// private subnets 정의 영역
resource "aws_subnet" "Private-subnet-01" {
  vpc_id            = aws_vpc.td-vpc-01.id
  cidr_block        = var.private-1_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terraform-private-1"
  }
}

resource "aws_subnet" "Private-subnet-02" {
  vpc_id            = aws_vpc.td-vpc-01.id
  cidr_block        = var.private-2_cidr
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terraform-private-2"
  }
}

resource "aws_subnet" "Private-subnet-03" {
  vpc_id            = aws_vpc.td-vpc-01.id
  cidr_block        = var.private-3_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terraform-private-3"
  }
}

resource "aws_subnet" "Private-subnet-04" {
  vpc_id            = aws_vpc.td-vpc-01.id
  cidr_block        = var.private-4_cidr
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terraform-private-4"
  }
}
resource "aws_subnet" "db-subnet-01" {
  vpc_id            = aws_vpc.td-vpc-01.id
  cidr_block        = var.db-subnet-1_cidr
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "terraform-db-subnet-1"
  }
}

resource "aws_subnet" "db-subnet-02" {
  vpc_id            = aws_vpc.td-vpc-01.id
  cidr_block        = var.db-subnet-2_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "terraform-db-subnet-2"
  }
}


// 인터넷 게이트웨이 (IGW) 정의 영역 
resource "aws_internet_gateway" "td_IGW" {
  vpc_id = aws_vpc.td-vpc-01.id // IGW 생성 후 연결 할 VPC ID 정의
  tags = {
    Name = "terraform-igw"
  }
}


// VPC 생성 시 자동생성되는 Default Routing Table TAG 설정
resource "aws_default_route_table" "public-route" {
  default_route_table_id = aws_vpc.td-vpc-01.default_route_table_id
  tags = {
    Name = "terraform-public-route"
  }
}

// Routing Table 정의 영역 ( route to Internet )
resource "aws_route" "public-route" {
  route_table_id         = aws_vpc.td-vpc-01.main_route_table_id // 규칙을 추가 할 Routing Table 지정
  destination_cidr_block = "0.0.0.0/0"                        // 목적지 CIDR Block
  gateway_id             = aws_internet_gateway.td_IGW.id // 위에서 정의한 목적지의 GW
}
# "main_route_table_id" : VPC 생성 시 자동으로 생성되는 Default Routing Table을 의미한다.


// NAT Gateway and EIP 정의 영역
resource "aws_eip" "td_vpc_eip1" {
  tags = {
    Name = "terraform-eip-1"
  }
}

resource "aws_nat_gateway" "td_nat1" {
  allocation_id = aws_eip.td_vpc_eip.id
  subnet_id     = aws_subnet.Public-subnet-01.id
}
# NAT GW에 EIP를 할당 후 Public Subnet 1번에 생성되도록 정의

resource "aws_eip" "td_vpc_eip2" {
  tags = {
    Name = "terraform-eip-2"
  }
}

resource "aws_nat_gateway" "td_nat2" {
  allocation_id = aws_eip.td_vpc_eip2.id
  subnet_id     = aws_subnet.Public-subnet-02.id
}
# NAT GW에 EIP를 할당 후 Public Subnet 2번에 생성되도록 정의


// Routing Table 정의 영역 ( Private Subnet Route )
// Private Routing Table 생성
resource "aws_route_table" "td-private-route1" {
  vpc_id = aws_vpc.td-vpc-01.id // Routing Table을 생성 할 VPC ID 정의
  tags = {
    Name = "terraform-private-route-1"
  }
}

resource "aws_route_table" "td-private-route2" {
  vpc_id = aws_vpc.td-vpc-01.id
  tags = {
    Name = "terraform-private-route-2"
  }
}

// Private Routing Table 정의
resource "aws_route" "td-private-route1" {
  route_table_id         = aws_route_table.td-private-route.id // 규칙을 추가 할 Routing Table 지정
  destination_cidr_block = "0.0.0.0/0"                                     // 목적지 CIDR Block
  nat_gateway_id         = aws_nat_gateway.td_nat1.id                // 위에서 정의한 목적지의 GW
}

resource "aws_route" "td-private-route2" {
  route_table_id         = aws_route_table.td-private-route2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.td_nat2.id
}


// Public Subnet -> Default Routing Table 연결
resource "aws_route_table_association" "my_vpc_public_subnet1_association" {
  subnet_id      = aws_subnet.Public-subnet-01.id
  route_table_id = aws_vpc.td-vpc-01.main_route_table_id
}

resource "aws_route_table_association" "my_vpc_public_subnet2_association" {
  subnet_id      = aws_subnet.Public-subnet-02.id
  route_table_id = aws_vpc.td-vpc-01.main_route_table_id
}

// Private Subnet -> Private Routing Table 연결
resource "aws_route_table_association" "my_vpc_private_subnet1_association" {
  subnet_id      = aws_subnet.Private-subnet-01.id
  route_table_id = aws_route_table.td-private-route1.id
}

resource "aws_route_table_association" "my_vpc_private_subnet2_association" {
  subnet_id      = aws_subnet.Private-subnet-02.id
  route_table_id = aws_route_table.td-private-route2.id
}

// Key Pair Data Source 영역
data "aws_key_pair" "EC2-Key" {
  key_name = "EC2-key"
}

// SSH 원격접속을 위한 Security-Group Resource 정의 
resource "aws_security_group" "BastionHost_sg" {
  name        = "BastionHost_Connection"
  description = "Allow SSH Traffic"
  vpc_id      = aws_vpc.td-vpc-01.id
  ingress {                     # In-Bound 규칙 
    from_port   = var.ssh_port  # 시작 포트번호
    to_port     = var.ssh_port  # 끝나는 포트번호
    protocol    = "tcp"         # 프로토콜 타입
    cidr_blocks = ["0.0.0.0/0"] # 허용 IP 범위
  }
  egress {                      # Out-Bound 규칙
    from_port   = 0             # 시작 포트번호
    to_port     = 0             # 끝나는 포트번호
    protocol    = "-1"          # 프로토콜 타입 ( "-1" = 모든 프로토콜 )
    cidr_blocks = ["0.0.0.0/0"] # 허용 IP 범위
  }
}


// EC2 Instance Resource 영역
resource "aws_instance" "BastionHost-1" {
  ami                         = "ami-0ea4d4b8dc1e46212"
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.EC2-Key.key_name
  availability_zone           = aws_subnet.Public-subnet-01.availability_zone
  subnet_id                   = aws_subnet.Public-subnet-01.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.BastionHost_sg.id]
  # 가용영역 Public Subnet 1과 동일한 영역을 사용하도록 정의
  # BastionHost 생성 Subnet 지정 ( Public Subnet 1 )
  # Public IP 부여 ( True )

  tags = {
    Name = "terraform-bastionHost-instance-1"
  }
}

// EC2 Instance Resource 영역
resource "aws_instance" "BastionHost-2" {
  ami                         = "ami-0ea4d4b8dc1e46212"
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.EC2-Key.key_name
  availability_zone           = aws_subnet.Public-subnet-02.availability_zone
  subnet_id                   = aws_subnet.Public-subnet-02.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.BastionHost_sg.id]
  # 가용영역 Public Subnet 1과 동일한 영역을 사용하도록 정의
  # BastionHost 생성 Subnet 지정 ( Public Subnet 1 )
  # Public IP 부여 ( True )

  tags = {
    Name = "terraform-bastionHost-instance-2"
  }
}

// BastionHost에 고정적인 Public IP를 부여하기 위해 EIP 설정을 함께 진행
resource "aws_eip" "BastionHost-1_eip" {
  instance = aws_instance.BastionHost-1.id
  tags = {
    Name = "BastionHost_EIP"
  }
}

resource "aws_eip" "BastionHost-2_eip" {
  instance = aws_instance.BastionHost-2.id
  tags = {
    Name = "BastionHost_EIP"
  }
}