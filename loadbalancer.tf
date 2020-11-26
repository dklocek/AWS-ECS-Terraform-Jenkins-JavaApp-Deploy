#TODO
/*resource "aws_alb_target_group" "ECS_TargetGroup" {
  name = var.Application_Name
  vpc_id = aws_vpc.ECS_VPC.id
  target_type = "ip"
  port        = 80
  protocol = "HTTP"
  tags = {
    Name = var.Application_Name
  }

  health_check {
    port = var.Container_Port
  }
}

resource "aws_alb" "ECS_AppLoadBalancer" {
  name = var.Application_Name
  internal = false
  load_balancer_type = "application"
  subnets = aws_subnet.Internet_Subnet.*.id
  tags = {
    Name = var.Application_Name
  }
}

resource "aws_alb_listener" "ECS_Listner" {
  load_balancer_arn = aws_alb.ECS_AppLoadBalancer.arn
  port = 8090
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.ECS_TargetGroup.arn
  }
}*/