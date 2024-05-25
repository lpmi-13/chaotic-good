resource "aws_vpc" "chaotic-good" {
  cidr_block = local.cidr_block

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

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  for_each       = local.subnets
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public.id
}

locals {
  cidr_block = "10.0.0.0/16"
  region     = "eu-west-1"
  subnets = {
    for i, v in ["a", "b", "c"] :
    "${local.region}${i}" =>
    {
      az   = "${local.region}${v}"
      cidr = cidrsubnet(local.cidr_block, 8, i)
    }
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = local.subnets

  vpc_id            = aws_vpc.chaotic-good.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = {
    Name = "chaotic-good-public-subnet"
  }
}

# just a place-holder until I can decide on something more permanent
resource "aws_route53_zone" "main" {
  name = "chaotic-good.org"
}
