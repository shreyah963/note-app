# Note-App - Two-Tier Web Application

This repository contains a complete two-tier web application deployment on AWS using modern DevOps practices, Terraform for Infrastructure as Code, and Kubernetes for container orchestration.

## Architecture

- **Frontend/Backend**: Containerized Go application running on EKS
- **Database**: MongoDB running on EC2 instance (outdated version for exercise)
- **Infrastructure**: Terraform-managed AWS resources
- **CI/CD**: GitHub Actions pipelines for automated deployment
- **Backup**: Automated daily MongoDB backups to S3

## Project Structure

```
note-app/
├── terraform/           # Infrastructure as Code
├── tasky-main/         # Go application source code
├── .github/workflows/  # CI/CD pipelines
└── README.md          # This file
```

## Quick Start

### Prerequisites
- AWS CLI configured
- Terraform installed
- kubectl configured for EKS

### Deployment Steps

1. **Deploy Infrastructure:**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy Application:**
   ```bash
   kubectl apply -f tasky-main/k8s/
   ```

3. **Access Application:**
   - Get ALB URL: `kubectl get ingress -n notes-app`
   - Or port-forward: `kubectl port-forward -n notes-app svc/notes-app-service 8080:80`

## CI/CD Pipelines

- **Infrastructure Pipeline**: Automatically deploys Terraform changes
- **Application Pipeline**: Builds, scans, and deploys Docker images
- **Security Pipeline**: Runs vulnerability scans on code and containers

## Security Features

- Automated security scanning with Trivy and tfsec
- Database backup automation
- Kubernetes RBAC (intentionally permissive for exercise)
- Public S3 bucket for backups (exercise requirement)

## Monitoring & Logs

- Application logs: `kubectl logs -n notes-app deployment/notes-app`
- Infrastructure logs: Check GitHub Actions
- Database backups: S3 bucket `mongo-backup-*`

## Cleanup

```bash
# Destroy infrastructure
cd terraform
terraform destroy

# Delete GitHub secrets
# Remove from GitHub repo settings
```

## Exercise Requirements Met

- Two-tier web application (frontend/database)
- Containerized application on Kubernetes
- Outdated MongoDB on EC2
- Public SSH access to EC2
- Automated database backups to S3
- Public-readable S3 bucket
- Infrastructure as Code (Terraform)
- CI/CD pipelines (GitHub Actions)
- Security scanning integration
- Overly permissive configurations (intentional)

## Notes

- This is a technical exercise with intentionally vulnerable configurations
- MongoDB is outdated and exposed for demonstration purposes
- S3 bucket is public for backup access requirement
- Kubernetes RBAC is overly permissive as required
- All configurations are for educational/demonstration purposes only

---

**Created by:** Shreya Bhatta  

