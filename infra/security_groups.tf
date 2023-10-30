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