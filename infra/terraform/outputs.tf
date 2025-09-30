output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "IDs of the database subnets"
  value       = module.vpc.database_subnets
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_node_groups" {
  description = "EKS node groups"
  value       = module.eks.eks_managed_node_groups
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.main.db_name
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "redis_port" {
  description = "Redis cluster port"
  value       = aws_elasticache_replication_group.redis.port
}

output "s3_app_data_bucket" {
  description = "S3 bucket for application data"
  value       = aws_s3_bucket.app_data.bucket
}

output "s3_ml_models_bucket" {
  description = "S3 bucket for ML models"
  value       = aws_s3_bucket.ml_models.bucket
}

output "s3_backups_bucket" {
  description = "S3 bucket for backups"
  value       = aws_s3_bucket.backups.bucket
}

output "secrets_manager_rds_arn" {
  description = "ARN of the Secrets Manager secret for RDS"
  value       = aws_secretsmanager_secret.rds_password.arn
}

output "secrets_manager_redis_arn" {
  description = "ARN of the Secrets Manager secret for Redis"
  value       = aws_secretsmanager_secret.redis_password.arn
}

output "secrets_manager_jwt_arn" {
  description = "ARN of the Secrets Manager secret for JWT"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "secrets_manager_api_keys_arn" {
  description = "ARN of the Secrets Manager secret for API keys"
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "iam_role_s3_access_arn" {
  description = "ARN of the IAM role for S3 access"
  value       = aws_iam_role.s3_access.arn
}

output "iam_role_secrets_access_arn" {
  description = "ARN of the IAM role for Secrets Manager access"
  value       = aws_iam_role.secrets_access.arn
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}