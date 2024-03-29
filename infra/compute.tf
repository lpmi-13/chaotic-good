resource "aws_key_pair" "terraform_keys" {
  key_name = "terraform_keys"
  public_key = file("ansible/terraform.ed25519.pub")
}

resource "aws_instance" "mongo" {
  count         = 3
  key_name = aws_key_pair.terraform_keys.key_name
  ami           = "ami-0d2a4a5d69e46ea0b"
  instance_type = "t3.large"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.default.id]

  tags = {
    Name = "MongoDB-${count.index}"
  }
}