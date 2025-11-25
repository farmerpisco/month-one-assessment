terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.20.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Techcorp-vpc"
  }
}

resource "aws_subnet" "tf_subnet_public1" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Techcorp-Public-Subnet-1"
  }
}

resource "aws_subnet" "tf_subnet_public2" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Techcorp-Public-Subnet-2"
  }
}

resource "aws_subnet" "tf_subnet_private1" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "tf_subnet_private2" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Techcorp-private-subnet-2"
  }
}