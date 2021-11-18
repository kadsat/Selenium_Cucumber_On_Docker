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
  region  = "us-east-2"
}
##### VPC ######
resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test_vpc"
  }
}
##### Subnet ######
resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "test_subnet"
  }
}

##### Internet Gateway ######
resource "aws_internet_gateway" "test_igw" {
    vpc_id = "${aws_vpc.test_vpc.id}"
    
    tags = {
        Name = "test_igw"
    }
}

############## Route Table &  Association ##############
resource "aws_route_table" "test_route_table" {
    vpc_id = "${aws_vpc.test_vpc.id}"
    route{
        cidr_block="0.0.0.0/0"
        gateway_id="${aws_internet_gateway.test_igw.id}"
    }

    tags = {
        Name="test_route_table"
    }
}

resource "aws_route_table_association" "route_tbl_link" {
  subnet_id = "${aws_subnet.test_subnet.id}"
  route_table_id = "${aws_route_table.test_route_table.id}"
}

####### Security Group ######
resource "aws_security_group" "ec2_sg" {
  name = "allow_http"
  vpc_id = "${aws_vpc.test_vpc.id}"
  ingress {
      from_port = 0
      to_port = 0
      protocol = "all"
      #security_groups = ["${aws_security_group.test_lb_sg.id}"]
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

###### EC2 #####
resource "aws_instance" "test_instance" {
	ami = "ami-0dd0ccab7e2801812"
	instance_type = "t2.micro"
    #availability_zone = "us-east-2b"
    subnet_id = "${aws_subnet.test_subnet.id}"
    vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]
    associate_public_ip_address = true
    user_data = "${file("userdata.sh")}"
	tags = {
		Name = "EC2one"
	}
}