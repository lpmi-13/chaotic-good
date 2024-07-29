
locals {
  cidr_block = "10.0.0.0/16"
  region     = "eu-west-1"
  private_subnets = {
    for i, v in ["a", "b", "c"] :
    "${local.region}${i}" =>
    {
      az   = "${local.region}${v}"
      cidr = cidrsubnet(local.cidr_block, 8, i)
    }
  }
  public_subnets = {
    for i, v in ["a", "b", "c"] :
    "${local.region}${i}" =>
    {
      az = "${local.region}${v}"
      # hacky +3, but oh well
      cidr = cidrsubnet(local.cidr_block, 8, i + 3)
    }
  }
}

resource "aws_vpc" "chaotic-good" {
  cidr_block = local.cidr_block

  # we need both of these to enable the VPC endpoints
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Chaotic Good VPC"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.chaotic-good.id
  tags = {
    Name = "chaotic-good-ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.chaotic-good.id
  tags = {
    Name = "chaotic-good-public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.chaotic-good.id
  tags = {
    Name = "chaotic-good-private-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private.id
}

# we only need an association for the Gateway endpoints. Interface endpoints don't work
# via routes, but use DNS entries directly
resource "aws_vpc_endpoint_route_table_association" "example" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_subnet" "private_subnet" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.chaotic-good.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "chaotic-good-private-subnet-${each.value.az}"
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.chaotic-good.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "chaotic-good-public-subnet-${each.value.az}"
  }
}

resource "aws_lb" "services-alb" {
  name               = "services-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  # enable this when we're ready for production
  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Chaotic     = "good"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.services-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chaotic-alb.arn
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "chaotic-good.org"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "chaotic-alb" {
  name = "chaotic-alb-target"
  # this target type is required for fargate task targets
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.chaotic-good.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.chaotic-good.id

  # this will explicitly have no ingress/egress rules since we don't want to use it
  tags = {
    Name = "do-not-use-default-sg"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.chaotic-good.id

  tags = {
    Name = "allow tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.chaotic-good.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "security group for the ECS tasks"
  vpc_id      = aws_vpc.chaotic-good.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_tls.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS Security group"
  }
}

resource "aws_security_group" "ecs-to-endpoint" {
  name        = "ECS to Endpoint"
  description = "allows ECS tasks to access the VPC endpoint"
  vpc_id      = aws_vpc.chaotic-good.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  tags = {
    Name = "ECS to Endpoint"
  }
}

# we'll add the DNS stuff for cloudfront later
resource "aws_route53_zone" "main" {
  name          = "chaotic-good.org"
  comment       = "the chaotic-good project domain"
  force_destroy = false
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id            = aws_vpc.chaotic-good.id
  service_name      = "com.amazonaws.eu-west-1.ecr.api"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  security_group_ids = [aws_security_group.ecs-to-endpoint.id]

  tags = {
    Name = "ECR API endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id            = aws_vpc.chaotic-good.id
  service_name      = "com.amazonaws.eu-west-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  security_group_ids = [aws_security_group.ecs-to-endpoint.id]

  tags = {
    Name = "ECR DKR endpoint"
  }
}


resource "aws_vpc_endpoint" "s3" {
  # we need this to be able to pull images in a private subnet, since the layers come from S3
  vpc_id            = aws_vpc.chaotic-good.id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "S3 Gateway Endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  # we need this to allow the tasks to push logs to cloudwatch
  vpc_id            = aws_vpc.chaotic-good.id
  service_name      = "com.amazonaws.eu-west-1.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ecs-to-endpoint.id]

  tags = {
    Name = "Cloudwatch logs Gateway Endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "ecr-api" {
  for_each        = aws_subnet.private_subnet
  vpc_endpoint_id = aws_vpc_endpoint.ecr-api.id
  subnet_id       = aws_subnet.private_subnet[each.key].id
}

resource "aws_vpc_endpoint_subnet_association" "ecr-dkr" {
  for_each        = aws_subnet.private_subnet
  vpc_endpoint_id = aws_vpc_endpoint.ecr-dkr.id
  subnet_id       = aws_subnet.private_subnet[each.key].id
}

resource "aws_vpc_endpoint_subnet_association" "cloudwatch_logs" {
  for_each        = aws_subnet.private_subnet
  vpc_endpoint_id = aws_vpc_endpoint.cloudwatch.id
  subnet_id       = aws_subnet.private_subnet[each.key].id
}
