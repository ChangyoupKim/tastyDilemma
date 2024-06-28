// ASG에서 사용 할 Security-Group Resource 정의 
resource "aws_security_group" "Web-Server_sg" {
  name        = "HTTP Web Server"
  description = "Allow HTTP Traffic"
  vpc_id      = var.vpc_id

  ingress {                     # In-Bound 규칙 
    from_port   = var.http_port # 시작 포트번호
    to_port     = var.http_port # 끝나는 포트번호
    protocol    = "tcp"         # 프로토콜 타입
    cidr_blocks = ["0.0.0.0/0"] # 허용 IP 범위
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {                      # Out-Bound 규칙
    from_port   = 0             # 시작 포트번호
    to_port     = 0             # 끝나는 포트번호
    protocol    = "-1"          # 프로토콜 타입 ( "-1" = 모든 프로토콜 )
    cidr_blocks = ["0.0.0.0/0"] # 허용 IP 범위
  }
}

resource "aws_security_group" "Was-Server_sg" {
  name        = "HTTP Was Server"
  description = "Allow HTTP Traffic"
  vpc_id      = var.vpc_id

  ingress {                     # In-Bound 규칙 
    from_port   = 22            # SSH 포트
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80            # HTTP 포트
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080          # 사용자 지정 TCP 포트
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443           # HTTPS 포트
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0             # 모든 트래픽
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {                      # Out-Bound 규칙
    from_port   = 0             # 시작 포트번호
    to_port     = 0             # 끝나는 포트번호
    protocol    = "-1"          # 프로토콜 타입 ( "-1" = 모든 프로토콜 )
    cidr_blocks = ["0.0.0.0/0"] # 허용 IP 범위
  }
}


// Web ASG (Auto Scaling Group) 시작 템플릿 영역
resource "aws_launch_configuration" "td_web_sever" {
  image_id        = "ami-0ea4d4b8dc1e46212"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.Web-Server_sg.id]
  # AMI 이미지 지정 및 EC2 Type, 보안그룹 정의

  user_data = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "Hello World from $(hostname -f)" > /var/www/html/index.html
  EOF
  # 인스턴스 초기 구성 스크립트를 USER-DATA로 정의 
  # Apache WEB Server 프로그램 설치 및 기본페이지 index.html 정의

  lifecycle {
    create_before_destroy = true
  }
  # 리소스의 수명주기 설정 ( lifecycle ) 
  # create_before_destroy : 교체 리소스를 생성 후 기존 리소스를 삭제
  # 테라폼은 리소스 변경사항을 확인하여 리소스를 유지하며 변경 할 수 있는 정보의 경우 기존 리소스에 새로운 변경사항을 반영한다.
  # 만약, AMI 이미지 교체등의 변경사항일 경우 기존 리소스를 유지하며 변경 할 수 없으므로, 기존 리소스를 삭제 후 새로운 리소스를 생성한다.
  # 기존 리소스를 먼저 삭제 후 새로운 리소스로 교체하는 경우 Service DownTime등의 문제가 발생 할 수 있다.
  # 이러한 문제들을 해결하기 위해서 테라폼에서는 리소스의 lifecycle 기능을 지원한다.
}

// Was ASG (Auto Scaling Group) 시작 템플릿 영역
resource "aws_launch_configuration" "td_was_sever" {
  image_id        = "ami-0ea4d4b8dc1e46212"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.Was-Server_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd.x86_64
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "Hello World from $(hostname -f)" > /var/www/html/index.html
  EOF

  lifecycle {
    create_before_destroy = true
  }
}


// ASG (Auto Scaling Group) 영역
resource "aws_autoscaling_group" "CodeDeploy_webServerDeployGroup" {
  launch_configuration = aws_launch_configuration.td_web_sever.name
  min_size             = var.min_size
  max_size             = var.max_size
  vpc_zone_identifier  = [var.private_subnet1, var.private_subnet2]
  # ASG 시작구성 정보를 불러오고 인스턴스의 최소 개수와 최대 개수를 정의
  # 인스턴스가 생성 될 Subnet을 명시 

  target_group_arns = [aws_lb_target_group.ALB-target.arn]
  health_check_type = "ALB"
  # ALB TagetGroup과 연결 ( ALB 작성을 모두 마치고 추가로 작업 )
  # ARN : Amazon Resource Name

  tag {
    key                 = "Name"
    value               = "terraform-web-server"
    propagate_at_launch = true
  }
  # ASG 시작구성으로 생성되는 인스턴스에 태그를 붙여준다.
}


// ALB ( Applicaion Load Balancing ) 영역
resource "aws_lb" "Alb" {
  name               = "terraform-web-server-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_sg.id]
  subnets            = [var.public_subnet1, var.public_subnet2]
  # ELB 이름정의 ( 알파벳, 하이픈("-") 으로만 구성 )
  # ELB Type 정의 (ALB)
  # ALB에 적용 할 보안그룹 지정 
  # ALB가 생성 될 Public Subnet을 지정 
}


resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.ALB-target.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 : Page Not Found"
      status_code  = "404"
    }
  }
  # ALB Listener를 위에서 생성한 ALB와 연결 
  # Listener는 기본 HTTP 프로토콜 80번 Port를 수신하도록 설정
  # Listener에서 정의 한 규칙과 일치하지 않는 요청의 경우 기본 응답 404 페이지를 리턴하도록 설정
}


resource "aws_lb_listener_rule" "my_lb_listener_rule" {
  listener_arn = aws_lb_listener.my_lb_listener.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_tg.arn
  }
  # 위에서 정의한 Listener에 연결 할 listener 규칙을 정의
  # priority : 연결 된 규칙이 여러개인 경우 우선순위를 결정하는 값으로 사용된다. ( 작은값 = 우선순위 높음 )
  # condition > path_pattern : 해당 규칙을 적용시킬 URI를 명시 ( "*" : 모든 경로에 대한 요청 )
  # action > target_group_arn : 해당 규칙에 Match되는 요청을 Forwarding 할 Target Group을 정의 
}


resource "aws_lb_target_group" "my_lb_tg" {
  name     = "my-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {                 # Target Group과 연결 된 ASG EC2 Instance 상태 체크 
    path                = "/"    # 상태 검사를 진행 할 URI 정의
    protocol            = "HTTP" # 상태 검사를 수행 할 Protocol (HTTP)
    matcher             = "200"  # HTTP 상태코드 값이 "200"인 경우 정상으로 판단
    interval            = 15     # 상태검사 주기 (15초)
    timeout             = 3      # 상태검사 응답대기 시간 (3초)
    healthy_threshold   = 3      # 연속 3번 정상 응답 -> 정상으로 판단
    unhealthy_threshold = 3      # 연속 3번 비정상 응답 -> 비정상으로 판단
  }
  # ALB가 Forwading 할 Target Group을 정의 ( 이름 : 알파벳, 하이픈만 사용가능 )
  # Target Group의 VPC를 정의하고 HTTP 80번 포트를 수신하도록 설정한다.
}
