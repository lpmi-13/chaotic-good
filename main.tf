terraform {
  backend "remote" {
    organization = "chaotic-good"

    workspaces {
      name = "terraform-cli"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

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

resource "aws_security_group" "default" {
  name        = "dungeon-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.dungeon.id
  depends_on  = [aws_vpc.dungeon]
  ingress = [
    {
      description = "let the ssh hit us"
      from_port = "22"
      to_port   = "22"
      protocol  = "tcp"
      security_groups = []
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids = []
      self = "true"
    }
  ]


  egress = [
    {
      description = "let us free!"
      from_port = "0"
      to_port   = "0"
      protocol  = "-1"
      security_groups = []
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      self      = "true"
    }
  ]

  tags = {
    Name = "allow_ssh"
    Environment = "DaDungeon"
  }
}

resource "aws_key_pair" "terraform_keys" {
  key_name = "terraform_keys"
  public_key = file("ansible/terraform.ed25519.pub")
}

resource "aws_instance" "mongo" {
  count         = 3
  key_name = aws_key_pair.terraform_keys.key_name
  ami           = "ami-028188d9b49b32a80"
  instance_type = "t3.large"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = {
    Name = "MongoDB-${count.index}"
  }
}

resource "aws_route53_zone" "main" {
  name = "chaotic-good.com"
}
