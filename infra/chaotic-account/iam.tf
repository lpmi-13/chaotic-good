# this is mostly for ECS, but we'll add more role stuff here later...

resource "aws_iam_role" "ecs-role" {
  name = "chaotic-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowECSAssumption"
        Principal = {
          Service = [
            "ecs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })

  tags = {
    tag-key = "iam-role-for-ecs"
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "chaotic-ecs-policy"
  role = aws_iam_role.ecs-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          # we'll add what we actually need later
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
