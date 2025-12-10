provider "aws" {
  region = "ap-south-1"
}

resource "aws_key_pair" "mykey" {
  key_name   = "ec2key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-security-group"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_server" {
  ami           = "ami-0f5ee92e2d63afc18" # Ubuntu latest (change if region mismatch)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name
  security_groups = [aws_security_group.nginx_sg.name]

  tags = {
    Name = "nginx-terraform-server"
  }
}
