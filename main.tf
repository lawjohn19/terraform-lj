provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "asg_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_one" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.asg_vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-one"
  }
}

resource "aws_subnet" "subnet_two" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.asg_vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-two"
  }
}

resource "aws_route_table" "asg_table" {
  vpc_id = aws_vpc.asg_vpc.id
  tags = {
    Name = "asg-route-table"
  }
}

resource "aws_route" "asg_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.asg_table.id
  gateway_id             = aws_internet_gateway.asg_igw.id
}

resource "aws_internet_gateway" "asg_igw" {
  vpc_id = aws_vpc.asg_vpc.id
  tags = {
    Name = "asg-internet-gateway"
  }
}

resource "aws_route_table_association" "subnet_one_association" {
  subnet_id      = aws_subnet.subnet_one.id
  route_table_id = aws_route_table.asg_table.id

}

resource "aws_security_group" "asg_sg" {
  vpc_id      = aws_vpc.asg_vpc.id
  name        = "asg-security-group"
  description = "Security group for ASG"
  tags = {
    Name = "asg-security-group"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "asg_lc" {
  name_prefix   = "asg-launch-template"
  image_id      = "ami-00a929b66ed6e0de6"
  instance_type = "t2.micro"
  key_name      = "twogem"

  user_data = base64encode(file("apache.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "asg-instance"
    }
  }
}



resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.subnet_one.id, aws_subnet.subnet_two.id]
  launch_template {
    id      = aws_launch_template.asg_lc.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_policy" "asg_scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_lb" "asg_alb" {
  name               = "asg-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.balancer_sg.id, aws_security_group.asg_sg.id]
  subnets            = [aws_subnet.subnet_one.id, aws_subnet.subnet_two.id]


  enable_deletion_protection = false

  enable_http2 = true

  tags = {
    Name = "asg-alb"
  }
}
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_lb_target_group.asg_target_group.arn

}

resource "aws_lb_target_group" "asg_target_group" {
  name       = "asg-target-group"
  depends_on = [aws_lb.asg_alb]
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.asg_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "asg-target-group"
  }
}

resource "aws_lb_listener" "listener_asg" {
  load_balancer_arn = aws_lb.asg_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_target_group.arn
  }
}

resource "aws_route_table_association" "subnet_two_association" {
  subnet_id      = aws_subnet.subnet_two.id
  route_table_id = aws_route_table.asg_table.id

}

# Define ALB SG
resource "aws_security_group" "balancer_sg" {
  name        = "balancer_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.asg_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_rule" {
  type                     = "ingress"
  security_group_id        = aws_security_group.balancer_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
}

resource "aws_security_group_rule" "egress_rule" {
  type                     = "egress"
  security_group_id        = aws_security_group.balancer_sg.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
}

resource "aws_security_group_rule" "ingress_rule1" {
  type                     = "ingress"
  security_group_id        = aws_security_group.balancer_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
}

resource "aws_security_group_rule" "egress_rule1" {
  type                     = "egress"
  security_group_id        = aws_security_group.balancer_sg.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
}

resource "aws_route" "asg_route1" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.asg_table.id
  gateway_id             = aws_internet_gateway.asg_igw.id
}

resource "aws_s3_bucket" "new-s3" {
  bucket = "new-ljs3"
}








