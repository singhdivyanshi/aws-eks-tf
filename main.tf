terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a VPC
resource "aws_vpc" "vpc_name" {
  cidr_block = var.cidr
  tags = {
    Name = var.vpc_name
}
}
# Allocate an Elastic IP resource
resource "aws_eip" "elastic_ip" {
   
}


# Subnet1
resource "aws_subnet" "vpc-subnet1" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.cidr-subnet1
  availability_zone = var.az1
  map_public_ip_on_launch = true
  

  tags = {
    Name = var.vpc-subnet1
    "kubernetes.io/cluster/${var.cluster}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

# Subnet2
resource "aws_subnet" "vpc-subnet2" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.cidr-subnet2
  availability_zone = var.az2
  map_public_ip_on_launch = false
  

  tags = {
    Name = var.vpc-subnet2
    "kubernetes.io/cluster/${var.cluster}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

# Subnet3
resource "aws_subnet" "vpc-subnet3" {
  vpc_id     = aws_vpc.vpc_name.id
  cidr_block = var.cidr-subnet3
  availability_zone = var.az3
  map_public_ip_on_launch = false
  

  tags = {
    Name = var.vpc-subnet3
    "kubernetes.io/cluster/${var.cluster}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.vpc_name.id

  tags = {
    Name = var.vpc-igw
  }
}

# NAT Gateway
resource "aws_nat_gateway" "vpc-nat" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.vpc-subnet1.id
  


  tags = {
    Name = var.vpc-nat
}
}

# Route Table 1 for Subnet1
resource "aws_route_table" "vpc-rt1" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-igw.id
  }

  tags = {
    Name = var.vpc-rt1
  }
}

# Route Table 2 for Subnet2
resource "aws_route_table" "vpc-rt2" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.vpc-nat.id
  }

  tags = {
    Name = var.vpc-rt2
  }
}

# Route Table 3 for Subnet3
resource "aws_route_table" "vpc-rt3" {
  vpc_id = aws_vpc.vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.vpc-nat.id
  }

  tags = {
    Name = var.vpc-rt3
  }
}

# Route Table 1 Association
resource "aws_route_table_association" "vpc-subnet1" {
  subnet_id      = aws_subnet.vpc-subnet1.id
  route_table_id = aws_route_table.vpc-rt1.id
}

# Route Table 2 Association
resource "aws_route_table_association" "vpc-subnet2" {
  subnet_id      = aws_subnet.vpc-subnet2.id
  route_table_id = aws_route_table.vpc-rt2.id
}

# Route Table 3 Association
resource "aws_route_table_association" "vpc-subnet3" {
  subnet_id      = aws_subnet.vpc-subnet3.id
  route_table_id = aws_route_table.vpc-rt3.id
}

#Security groups
resource "aws_security_group" "demogroups" {
  name_prefix = "ssh-access-demogroup"
  vpc_id      = aws_vpc.vpc_name.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing SSH from all IPs
  }

  ingress {
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
}

ingress {
  from_port   = 0
  to_port     = 65535
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]  
}

ingress {
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]  
}


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-access-demogroup"
  }
}

# IAM Role for EKS
resource "aws_iam_role" "cluster1" {   /////////////////////////////////////////////////////////////
  name = "cluster1"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster1.name
}
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  role       = aws_iam_role.cluster1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Define EKS cluster using terraform-aws-modules
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster
  version         = "20.31.1"
  vpc_id          = aws_vpc.vpc_name.id
  subnet_ids      = [aws_subnet.vpc-subnet2.id, aws_subnet.vpc-subnet3.id]
  iam_role_name                     = aws_iam_role.cluster1.name
  cluster_endpoint_public_access    = false
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
  }
}

# IAM Role for Node Group
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role1"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach policies to the node group IAM role
resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EKS managed node group
module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

   name            = "separate-eks-mng"
   cluster_name    =  var.cluster
   version        = "20.31.1"
   instance_types = var.eks-node
   cluster_service_cidr = "10.100.0.0/16"  

  subnet_ids = [aws_subnet.vpc-subnet2.id]
  

  min_size     = 1
  max_size     = 3
  desired_size = 2
  capacity_type  = "SPOT"

  labels = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
