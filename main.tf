provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "lj_vpc1" {
    cidr_block = "10.0.0.0/16"
}
