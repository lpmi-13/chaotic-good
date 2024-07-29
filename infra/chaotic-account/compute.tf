# we need a fargate cluster, a fargate service, and a task defintion

resource "aws_ecs_cluster" "chaotic-good" {
  name = "chaotic-good"

  # we might enable container insights for this...not sure yet
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ecs_service" "chaotic-service" {
  name            = "chaotic-service"
  cluster         = aws_ecs_cluster.chaotic-good.id
  task_definition = aws_ecs_task_definition.chaotic-service.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.chaotic-alb.arn
    container_name   = "chaotic-service"
    container_port   = 8001
  }

  network_configuration {
    subnets         = [for subnet in aws_subnet.private_subnet : subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  launch_type = "FARGATE"

  # makes it easier to pass tags to the running tasks
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
}

resource "aws_ecs_task_definition" "chaotic-service" {
  family                   = "chaotic-service"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  network_mode = "awsvpc"
  cpu          = 256
  memory       = 512
  container_definitions = jsonencode([
    {
      name = "chaotic-service"
      # add the image ARN here
      image     = aws_ecr_repository.chaotic-backend.repository_url
      essential = true
      portMappings = [
        {
          containerPort = 8001
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/chaotic-service"
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "chaotic-backend" {
  name              = "/ecs/chaotic-service"
  retention_in_days = 5

  tags = {
    Application = "chaotic-backend"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
