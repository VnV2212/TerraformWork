# data "aws_availability_zones" "all" {
# }

# resource "aws_security_group" "instance" {
#   name = "terraform-example-instance"
  
#   ingress {
#     from_port	  = "${var.server_port}"
#     to_port		  = "${var.server_port}"
#     protocol	  = "tcp"
#     cidr_blocks	= ["0.0.0.0/0"]
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_security_group" "elb" {
#   name = "terraform-example-elb"
  
#   ingress {
#     from_port	  = 80
# 	  to_port		  = 80
# 	  protocol	  = "tcp"
# 	  cidr_blocks	= ["0.0.0.0/0"]
#   }

#   egress {
#     from_port	  = 0
# 	  to_port		  = 0
# 	  protocol	  = "-1"
# 	  cidr_blocks	= ["0.0.0.0/0"]
#   }
# }

# resource "aws_launch_configuration" "example" {
#   image_id		    = "ami-0f2e255ec956ade7f"
#   instance_type   = "t2.micro"
#   security_groups = ["${aws_security_group.instance.id}"]
  
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p "${var.server_port}" &
#               EOF
			  
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "example" {
#   launch_configuration = "${aws_launch_configuration.example.id}"
#   availability_zones   = ["${data.aws_availability_zones.all.names[0]}"]
  
#   load_balancers       = ["${aws_elb.example.name}"]
#   health_check_type    = "ELB"
  
#   min_size = 2
#   max_size = 10
  
# }

# resource "aws_elb" "example" {
#   name               = "terraform-asg-example"
#   availability_zones = ["${data.aws_availability_zones.all.names[1]}"]
#   security_groups    = ["${aws_security_group.elb.id}"]
  
#   listener {
#     lb_port           = 80
#     lb_protocol       = "http"
#     instance_port     = "${var.server_port}"
#     instance_protocol = "http"
#   }
  
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     interval            = 30
#     target              = "HTTP:${var.server_port}/"
#   }
# }

# resource "aws_s3_bucket" "mybucket" {
#   bucket = "mybucketvnv"
# }
#################################################

# VPC
# resource "aws_vpc" "default" {
#   cidr_block = "10.0.0.0/16"
# }

# # internet gateway
# resource "aws_internet_gateway" "default" {
#   vpc_id = aws_vpc.default.id
# }

# resource "aws_route" "internet_access" {
#   route_table_id         = aws_vpc.default.main_route_table_id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.default.id
# }

module "base" {
  source = "Users/vatsalparmar/terraform-course/module"
  cidr = "10.0.0.0/16"
}

#route table
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public-1-a" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.main-public.id
}

# public subnet
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
}

# private subnet
resource "aws_subnet" "private" {
  

  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-south-1a"


}

# security group for ELB
resource "aws_security_group" "elb" {
  name        = "terraform_elb"
  vpc_id      = aws_vpc.default.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group to access the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {  
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "terraform-elb"

  subnets         = [aws_subnet.default.id]
  security_groups = [aws_security_group.elb.id]
  instances       = [aws_instance.web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "web" {

  instance_type = "t2.micro"
  ami = var.AMIS[var.AWS_REGION]

  vpc_security_group_ids = [aws_security_group.default.id]

  subnet_id = aws_subnet.default.id
}
