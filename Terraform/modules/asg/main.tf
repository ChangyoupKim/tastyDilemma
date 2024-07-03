# AWS KEY-Pair Data Source (Update)
data "aws_key_pair" "EC2-Key" {
  key_name = "EC2-key"
}

resource "aws_launch_configuration" "aws_asg_launch" {
  image_id        = "ami-0ea4d4b8dc1e46212"
  instance_type   = var.instance_type
  security_groups = [var.SSH_SG_ID, var.HTTP_HTTPS_SG_ID]
  key_name        = data.aws_key_pair.EC2-Key.key_name # (Update)
  user_data       = <<-EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd.x86_64
    sudo amazon-linux-extras install epel -y
    sudo yum -y install stress
    sudo yum -y install htop
    systemctl start httpd.service
    systemctl enable httpd.service
    echo "DB Endpoint: ${data.terraform_remote_state.rds_remote_data.outputs.rds_instance_address}" > /var/www/html/index.html
    echo "DB Port: ${data.terraform_remote_state.rds_remote_data.outputs.rds_instance_port}" >> /var/www/html/index.html
    echo "<h1>Hello My WEB</h1>" > /var/www/html/index.html
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Desired_Size 지정
resource "aws_autoscaling_group" "aws_asg" {
  # Launch Configuration 변경 시 새로운 ASG가 배포되도록 의존관계를 Name으로 정의한다.
  name                 = "${var.name}-${aws_launch_configuration.aws_asg_launch.name}"
  launch_configuration = aws_launch_configuration.aws_asg_launch.name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.private_subnets
  target_group_arns    = [data.terraform_remote_state.alb_remote_data.outputs.ALB_TG] # (Update)
  health_check_type    = "ELB"

  # 교체용 ASG 생성 후 기존 ASG 삭제를 위한 LifeCycle 설정
  lifecycle {
    create_before_destroy = true
  }

  # 교체용 ASG 배포 완료를 고려하기 전 최소 인스턴스 수 만큼 상태검사를 통과할 때까지 대기 후 배포완료
  min_elb_capacity  = var.min_size

  tag {
    key                 = "Name"
    value               = "${var.name}-Terraform_Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.name}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.aws_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.name}-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aws_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.name}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.aws_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.name}-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aws_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in_policy.arn]
}
