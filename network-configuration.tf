terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-eks-vpc"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "my-eks-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "my-eks-private-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "my-eks-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "my-eks-public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_subnet_association" "public_subnet_assoc_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet_association" "public_subnet_assoc_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "eks_sg" {
  name = "eks-security-group"
  description = "Security group for EKS nodes"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
