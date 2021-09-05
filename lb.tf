resource "aws_lb" "main" {
  name                             = "lbapi"
  enable_cross_zone_load_balancing = "false"
  enable_deletion_protection       = "false"
  internal                         = "true"
  ip_address_type                  = "ipv4"
  load_balancer_type               = "network"
  subnets                          = ["subnet-231f457c","subnet-7a2d741c"]
  #  security_groups                  = [aws_security_group.lb.id]
  
}

resource "aws_lb_target_group" "app" {
  name        = "tf-ecs-TG"
  port        = 80
  protocol    = "TCP"
  vpc_id      = "vpc-4889e335"
  target_type = "ip"

 
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.app.id
    type             = "forward"
  }
}
                  
