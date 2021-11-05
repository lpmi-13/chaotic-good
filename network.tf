resource "aws_vpc" "dungeon" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "DungeonVPC"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.dungeon.id
  tags = {
    Name = "dungeon-ig"
    Environment = "dungeon"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dungeon.id
  tags = {
    Name = "dungeon-public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.dungeon.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-dungeon-subnet"
  }
}

# just a place-holder until I can decide on something more permanent
resource "aws_route53_zone" "main" {
  name = "chaotic-good.com"
}
