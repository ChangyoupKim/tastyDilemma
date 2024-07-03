resource "aws_lb" "aws_alb" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  security_groups    = [var.HTTP_HTTPS_SG_ID]
  subnets            = var.public_subnets
}

resource "aws_lb_listener" "aws_alb_listener" {
  load_balancer_arn = aws_lb.aws_alb.arn
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
}

resource "aws_lb_target_group" "aws_alb_tg" {
  name     = "${var.name}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "aws_alb_listener_rule" {
  listener_arn = aws_lb_listener.aws_alb_listener.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_alb_tg.arn
  }
}
