// 테스트를 위해 ALB에 할당되는 Domain Name 출력 Output 정의
output "ALB_DNS" {
  value = aws_lb.my_lb.dns_name
  description = "Load Balancer Domain Name"
}