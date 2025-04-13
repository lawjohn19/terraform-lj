provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "jenkins-web" {
  ami                         = "ami-075686beab831bb7f"
  instance_type               = "t2.micro"
  key_name                    = "safekey"
  subnet_id                   = aws_subnet.new_sub1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.newgrp.id]
  user_data                   = file("jenks.sh")

  tags = {
    Name = "Jenkins-Web"
  }
}

resource "aws_security_group" "newgrp" {
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.new_vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
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
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "newgrp"
  }
}

resource "aws_vpc" "new_vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "new_vpc1"
  }
}

resource "aws_subnet" "new_sub1" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.new_vpc1.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "new_sub1"
  }
}

resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.new_vpc1.id
  tags = {
    Name = "new_rt1"
  }
}

resource "aws_route" "route1" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route_table1.id
  gateway_id             = aws_internet_gateway.igw1.id
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.new_vpc1.id
  tags = {
    Name = "new_igw1"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.new_sub1.id
  route_table_id = aws_route_table.route_table1.id
}

resource "aws_s3_bucket" "jenksone-ljone" {
  bucket = "jenksone-ljone"
}