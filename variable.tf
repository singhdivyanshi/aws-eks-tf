variable "aws_region" {
    description = "my aws region"
  
}
variable "access_key" {
    description = "aws access key"
  
}

variable "secret_key" {
    description = "aws secret key"
  
}

variable "vpc_name" {
    description = "my vpc"
  
}

variable "cidr" {
    description = "vpc cidr"
  
}

# Variable for Elastic IP
variable "vpc-elastic_ip" {
  description = "The Elastic IP for the NAT Gateway"
  type        = string
}

variable "vpc-subnet1" {
    description = "vpc public subnet"
  
}

variable "cidr-subnet1" {
    description = "public subnet cidr"
  
}

variable "az1" {
    description = "availability zone of subnet-1"
  
}

variable "vpc-subnet2" {
    description = "vpc private subnet"
  
}

variable "cidr-subnet2" {
    description = "private subnet cidr"
  
}

variable "az2" {
    description = "availability zone of subnet-2"
  
}

variable "vpc-subnet3" {
    description = "vpc private subnet"
  
}

variable "cidr-subnet3" {
    description = "private subnet cidr"
  
}

variable "az3" {
    description = "availability zone of subnet-2"
  
}

variable "vpc-igw" {
    description = "internet gateway for vpc"
  
}

variable "vpc-nat" {
    description = "vpc nat gateway"
  
}

variable "vpc-rt1" {
    description = "route table 1 for public subnet"
  
}

variable "vpc-rt2" {
    description = "route table 2 for private subnet"
  
}

variable "vpc-rt3" {
    description = "route table 3 for private subnet"
  
}

variable "cluster" {
    description = "eks cluster"
  
}

variable "eks-node" {
  description = "Instance types for EKS nodes"
}