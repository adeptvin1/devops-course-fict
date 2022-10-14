terraform {
  required_providers{
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0" 
}

provider "aws" {
    region = "eu-central-1"
}
resource "aws_instance" "my_first_instance" {
    ami = "ami-0caef02b518350c8b"
    instance_type = "t2.micro"
    tags = {
        Name: "first_instance"
    }
}   