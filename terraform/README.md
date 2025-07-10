# Terraform Infrastructure for Wiz Technical Exercise

This folder contains the Infrastructure-as-Code (IaC) for deploying the required AWS environment for the Wiz technical exercise.

## Structure

- `main.tf` - Root Terraform configuration, calls all modules
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `provider.tf` - AWS provider configuration
- `versions.tf` - Required Terraform and provider versions
- `modules/` - Reusable infrastructure modules (VPC, EC2, EKS, S3, IAM, etc.)
- `environments/` - Environment-specific configurations (dev, prod)

## Getting Started

1. Copy `environments/dev` as needed for your environment.
2. Run `terraform init` to initialize.
3. Run `terraform plan` to review changes.
4. Run `terraform apply` to deploy.

## Security Weaknesses (for demo)
- Outdated OS and MongoDB
- Public SSH
- Overly permissive IAM
- Public S3 bucket
- K8s admin role for app

## Next Steps
- Fill in each module and environment as needed. 