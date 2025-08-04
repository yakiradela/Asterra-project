#####################
# VPC and Networking
#####################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

#########################
# Security Groups
#########################

resource "aws_security_group" "rdp_sg" {
  name   = "${var.project_name}-rdp"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.allowed_rdp_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_sg" {
  name        = "${var.project_name}-eks-sg"
  description = "Allow HTTPS inbound traffic to EKS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-sg"
  }
}

#########################
# RDS Cluster
#########################

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "private-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier      = "${var.project_name}-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = var.db_engine_version
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rdp_sg.id]
  skip_final_snapshot     = true
  storage_encrypted       = true

  serverlessv2_scaling_configuration {
    min_capacity = 1
    max_capacity = 3
  }
}

resource "aws_rds_cluster_instance" "postgres_instance" {
  count                   = var.db_instance_count
  identifier              = "${var.project_name}-instance-${count.index + 1}"
  cluster_identifier      = aws_rds_cluster.postgres_cluster.id
  instance_class          = var.db_instance_class
  engine                  = aws_rds_cluster.postgres_cluster.engine
  engine_version          = aws_rds_cluster.postgres_cluster.engine_version
  publicly_accessible     = false
}

#########################
# S3 & ECR
#########################

resource "aws_s3_bucket" "geojson_bucket" {
  bucket        = "${var.project_name}-geojson-input"
  force_destroy = true
}

resource "aws_ecr_repository" "ecr-repo" {
  name = "${var.project_name}-repo"
}

#########################
# EKS Module
#########################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.0" # גרסה עם תמיכה בפרמטרים הדרושים

  name               = var.project_name
  kubernetes_version = "1.29"

  vpc_id     = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id,
  ]

  security_group_id             = aws_security_group.eks_sg.id
  additional_security_group_ids = [aws_security_group.eks_sg.id]

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # ניהול הרשאות IAM ב־aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::557690607676:role/astera-devops-cluster-20250803164116409800000001"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  addons = {
    coredns = {
      most_recent                  = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "NONE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size               = 1
      max_size               = 3
      desired_size           = var.node_count
      instance_types         = ["t3.medium"]
      vpc_security_group_ids = [aws_security_group.eks_sg.id]
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

