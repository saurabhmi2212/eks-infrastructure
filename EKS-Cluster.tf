# Configure AWS credentials and region
provider "aws" {
  region = "us-east-1" # Replace with  desired region
}

# Create VPC
resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "eks-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "eks-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "eks-public-subnet-2"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "eks-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.eks.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "eks-private-subnet-2"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks.id
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks.id
}

# Create public route
resource "aws_route" "public_route" {
  route_table_id     = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id   

}

# Associate public route table with public subnets
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id   
 = aws_route_table.public_route_table.id
}

resource "aws_route_table_association"   
 "public_subnet_2_association" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id   

}

# Create security group for EKS control plane
resource "aws_security_group" "eks_control_plane_sg" {
  name = "eks-control-plane-sg"
  vpc_id = aws_vpc.eks.id
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
}

resource "aws_eks_cluster" "eks" {
  name = "my-eks-cluster"
  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id   

    ]
    security_group_ids = [
      aws_security_group.eks_control_plane_sg.id
    ]
  }
  cluster_config {
    version = "1.24" # Replace with  desired EKS version
    node_group_configs = [
      {
        node_group_name = "default-node-group"
        desired_size = 2
        min_size = 1
        max_size = 5
        ami_type = "AL2"
        labels = {
          "eks.amazonaws.com/nodegroup" = "default"
        }
        node_group_capacity_type = "ON_DEMAND"
      }
    ]
  }
}
