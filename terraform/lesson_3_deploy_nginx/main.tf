terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "serviceaccount" {
  key_name   = "sa_key"
  public_key = "YOUR_PUBLIC_KEY"
}


resource "aws_security_group" "sg_nginx_instance" {
  name = "sg_nginx_instance"
  description = "Allow SSH and HTTP"
  vpc_id = "YOUR_VPC_ID"
}

resource "aws_security_group_rule" "ssh_in" {
    type = "ingress"
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.sg_nginx_instance.id
}
  
resource "aws_security_group_rule" "http_in" {
    type = "ingress"
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.sg_nginx_instance.id
}

resource "aws_security_group_rule" "public_out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = aws_security_group.sg_nginx_instance.id
}

resource "aws_instance" "nginx_instance" {
  ami           = "ami-0caef02b518350c8b"
  instance_type = "t2.micro"
  key_name      = "sa_key"
  vpc_security_group_ids = [ "${aws_security_group.sg_nginx_instance.id}" ]
  tags = {
    Name : "nginx_instance"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt install -y nginx",
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key  = file("./sa_user")
      host = self.public_ip
    }
  }
}


output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.nginx_instance.public_ip
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.nginx_instance.private_ip
}