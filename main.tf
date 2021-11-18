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

###### ALB Security Group ######
#resource "aws_security_group" "test_lb_sg" {
#  name = "test_lb_sg"
#  description = "Load balancer security group"
#  vpc_id = "${aws_vpc.test_vpc.id}"
#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
######### ALB ############
#resource "aws_lb" "test_lb" {
#    name = "test-lb"
#    internal = false
#    load_balancer_type = "application"
#    security_groups = ["${aws_security_group.test_lb_sg.id}"]
#    subnets = ["${aws_subnet.test_subnet.id}"]
#}
###### ALB Target Group
#resource "aws_alb_target_group" "test_lb_tg" {
#  name = "test-lb-tg"
#  port = 80
#  protocol = "HTTP"
#  vpc_id = "${aws_vpc.test_vpc.id}"
#
#}
####### LB Listner #####
#resource "aws_alb_listener" "test_lb_listner" {
#  load_balancer_arn = "${aws_lb.test_lb.arn}"
#  port = "80"
#  protocol = "HTTP"
#  default_action {
#      target_group_arn = "${aws_alb_target_group.test_lb_tg.arn}"
#      type = "forward"
#  }
#}

#variable "sg_ingress_rules" {
#    type = list(object({
#      from_port   = number
#      to_port     = number
#      protocol    = string
#      cidr_block  = string
#      description = string
#    }))
#    default     = [
#        {
#          from_port   = 22
#          to_port     = 22
#          protocol    = "tcp"
#          cidr_block  = "0.0.0.0/0"
#          description = "test"
#        },
#        {
#          from_port   = 80
#          to_port     = 80
#          protocol    = "tcp"
#          cidr_block  = "0.0.0.0/0"
#          description = "test"
#        },
#    ]
#}
#resource "aws_security_group_rule" "ingress_rules" {
#  count = length(var.ingress_rules)
#  type              = "ingress"
#  from_port         = var.ingress_rules[count.index].from_port
#  to_port           = var.ingress_rules[count.index].to_port
#  protocol          = var.ingress_rules[count.index].protocol
#  cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
#  description       = var.ingress_rules[count.index].description
#  security_group_id = aws_security_group.ec2_security_groups.id
#}
#
#resource "aws_security_group_rule" "egress_rules" {
#  count = length(var.ingress_rules)
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = -1
#  cidr_blocks       = ["0.0.0.0/0"]
#  description       = "egress rules"
#  security_group_id = aws_security_group.ec2_security_groups.id
#}

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

####### Target group attachment #####
#resource "aws_alb_target_group_attachment" "alb_instance1" {
#  target_group_arn = "${aws_alb_target_group.test_lb_tg.arn}"
#  target_id = "${aws_instance.test_instance.id}"
#  port = 80
#}