resource "aws_ecs_task_definition" "ECS_Task_Definition" {
  requires_compatibilities = ["FARGATE"]
  family = var.Application_Name
  task_role_arn = var.Task_Role_Arn
  execution_role_arn = var.Execution_Role_Arn
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  container_definitions = <<DEF
  [{
    "name": "Test_Application",
    "image": "${var.ECR_Image}",
    "cpu": ${var.Definition_CPU},
    "memory": ${var.Definition_Memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.Container_Port},
        "hostPort": ${var.Host_Port}
      }
    ]
  }]
  DEF

  tags = {
    Name = var.Application_Name
  }
}

resource "aws_ecs_cluster" "ECS_Cluster" {
  name = "${var.Application_Name}_Cluster"
  capacity_providers = ["FARGATE","FARGATE_SPOT"]
  tags = {
    Name = var.Application_Name
  }
}


resource "aws_ecs_service" "ECS_Service" {
  launch_type       = "FARGATE"
  platform_version  = "LATEST"
  cluster           = aws_ecs_cluster.ECS_Cluster.name
  name              = "${var.Application_Name}_Service"
  task_definition   = aws_ecs_task_definition.ECS_Task_Definition.arn

  desired_count     = 3

  deployment_maximum_percent         = 300
  deployment_minimum_healthy_percent = 100

  network_configuration {
      subnets = aws_subnet.ESC_Subnet.*.id
  }
  tags = {
    Name = var.Application_Name
  }
}

