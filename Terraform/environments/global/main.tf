terraform {
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


# AWS S3 Bucket 생성
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tastydilemma-terraform-state"
  tags = {
    Name = "terraform_state"
  }
  # bucket의 이름은 AWS 전체 사용자내에서 고유한 이름으로 설정
  # 이름은 반드시 알파벳 소문자, "-"(하이픈) 으로만 작성해야한다.

  lifecycle {
    #prevent_destroy = true
  }
  # S3와 같은 중요한 서비스는 실수로 삭제되지 않도록 Lifecycle을 정의한다.
  # 실제 삭제 작업을 진행하고 싶은 경우 주석처리를 진행한다.

  force_destroy = true
  # S3 bucket 강제삭제 가능 옵션 ( 데이터가 저장되어있는 Bucket은 삭제가 불가능 )
  # 강제 삭제 옵션을 활성화 할 경우 데이터가 존재하여도 삭제가 가능하다.
}


# S3 bucket에서 사용 할 KMS 리소스 정의
resource "aws_kms_key" "terraform_state_kms" {
  description             = "terraform_state_kms"
  deletion_window_in_days = 7
  # 삭제대기 유효기간: 7일 ( 삭제 유예기간 설정 )
}


# S3 bucket 암호화 (KMS 방식 사용)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_sec" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_versioning" "terraform_state_ver" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
  # S3 Bucket 버전관리 ( 업데이트 마다 새로운 버전을 생성 )
  # 버전 관리를 진행하여 언제든지 이전 버전 상태로 되돌아 갈 수 있다.
}


# 다이나모 DB : AWS의 분산형 KEY-Value 저장소
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tastydilemma-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  # DynamoDB 테이블 생성 ( Primary KEY : "LockID" )
  # DynamoDB의 잠금기능을 사용하기 위해서는 반드시 위 제약조건을 정의해야 한다.
}
