terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source               = "./modules/ec2"
  ami                  = "ami-0c7217cdde317cfec"
  instance_type        = "t3.medium"
  subnet_id            = module.vpc.public_subnet_id
  vpc_id               = module.vpc.vpc_id
  name                 = "wiz"
  k8s_cidr             = "10.0.0.0/16"
  iam_instance_profile = module.iam.instance_profile
  s3_bucket            = module.s3.bucket_name
}

module "s3" {
  source = "./modules/s3"
}

module "iam" {
  source = "./modules/iam"
  name   = "wiz"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "wiz-eks-${random_id.suffix.hex}"
  cluster_version = "1.27"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = [module.vpc.private_subnet_id, module.vpc.private_subnet_id_2]
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
      subnet_ids     = [module.vpc.private_subnet_id, module.vpc.private_subnet_id_2]
      iam_role_additional_policies = {
        AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
      }
    }
  }
  tags = {
    Name = "wiz-eks"
  }
}

# Cloud Native Security Controls
module "security" {
  source = "./modules/security"
  # Set to true if you have AWS Organizations access
  create_organization_policy = false
  # Log retention settings
  cloudtrail_log_retention_days = 30
  config_log_retention_days     = 30
} 