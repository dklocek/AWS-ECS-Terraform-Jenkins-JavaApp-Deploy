#TODO
resource "aws_alb_target_group" "ECS_TargetGroup" {
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

  depends_on = [aws_alb.ECS_AppLoadBalancer]
}

resource "aws_alb" "ECS_AppLoadBalancer" {
  name = var.Application_Name
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ECS_LB_SG.id]
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
}

resource "aws_security_group" "ECS_LB_SG" {
  vpc_id = aws_vpc.ECS_VPC.id
  name = var.Application_Name
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    name = "${var.Application_Name}_SG"
  }
}


