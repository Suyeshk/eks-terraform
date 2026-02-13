terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
terraform {
  backend "s3" {
    bucket         = "terraform-state-lock-sk"
    key            = "eks/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# --------------------------
# EKS Cluster
# --------------------------

resource "aws_eks_cluster" "demo" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
 security_group_ids = [aws_security_group.eks_cluster_sg.id]
  endpoint_public_access = true
  }

  tags = {
    Environment = terraform.workspace
  }
}

# --------------------------
# Managed Node Group
# --------------------------

resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_eks_cluster.demo
  ]

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "eks_cluster_sg" {
  name   = "${var.cluster_name}-cluster-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow worker nodes to communicate with control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For testing only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "eks_node_sg" {
  name   = "${var.cluster_name}-node-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow node to node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow control plane to talk to nodes"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

