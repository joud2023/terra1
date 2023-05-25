terraform {
  required_providers {
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "192.168.20.0/24"
  availability_zone = "eu-central-1a"
}
resource "aws_security_group" "my_security_group" {
  name = "my_security_group"
  vpc_id = aws_vpc.my_vpc.id
    ingress {
    from_port   = 0
    to_port     = 0
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
resource "aws_instance" "my_instance" {
  ami =  "ami-03aefa83246f44ef2"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.my_security_group.id]
  tags = {
    Name = "My EC2 Instance"
  }
}
resource "ansible_host" "my_ec2" {          #### ansible host details
  name   = aws_instance.my_instance.public_dns
  groups = ["nginx"]
  variables = {
    ansible_user                 = "ansible",
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
ansible_python_interpreter   = "/usr/bin/python3"
}
}
