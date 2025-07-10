output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "mongo_public_ip" {
  description = "Public IP of MongoDB instance"
  value       = module.ec2.public_ip
}

output "s3_backup_bucket" {
  description = "S3 bucket for MongoDB backups"
  value       = module.s3.bucket_name
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
} 