# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.project_name}-${var.environment}"
  description                = "Redis cluster for ${var.project_name} ${var.environment}"
  
  node_type                  = "cache.t3.micro"
  port                       = 6379
  parameter_group_name       = "default.redis7"
  
  num_cache_clusters         = 2
  auto_minor_version_upgrade = true
  
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
  
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_password.result
  
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-redis"
  }
}

# Generate random password for Redis
resource "random_password" "redis_password" {
  length  = 32
  special = false  # Redis auth token cannot contain special characters
}

# Store Redis password in Secrets Manager
resource "aws_secretsmanager_secret" "redis_password" {
  name = "${var.project_name}-${var.environment}-redis-password"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-redis-password"
  }
}

resource "aws_secretsmanager_secret_version" "redis_password" {
  secret_id = aws_secretsmanager_secret.redis_password.id
  secret_string = jsonencode({
    password = random_password.redis_password.result
    host     = aws_elasticache_replication_group.redis.configuration_endpoint_address
    port     = aws_elasticache_replication_group.redis.port
  })
}

# CloudWatch Log Group for Redis
resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/elasticache/${var.project_name}-${var.environment}/redis-slow-log"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-slow-log"
  }
}

# Secrets Manager for JWT Secret
resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project_name}-${var.environment}-jwt-secret"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-jwt-secret"
  }
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({
    secret = random_password.jwt_secret.result
  })
}

# Secrets Manager for API Keys
resource "aws_secretsmanager_secret" "api_keys" {
  name = "${var.project_name}-${var.environment}-api-keys"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-api-keys"
  }
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    coinbase_api_key    = ""
    binance_api_key     = ""
    twitter_api_key     = ""
    reddit_client_id    = ""
    news_api_key        = ""
    telegram_bot_token  = ""
    discord_bot_token   = ""
  })
}

# IAM Role for Secrets Manager Access
resource "aws_iam_role" "secrets_access" {
  name = "${var.project_name}-${var.environment}-secrets-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.cluster.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub" = "system:serviceaccount:default:crypto-ai-analytics"
            "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-secrets-access"
  }
}

resource "aws_iam_policy" "secrets_access" {
  name        = "${var.project_name}-${var.environment}-secrets-access"
  description = "Policy for Secrets Manager access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.rds_password.arn,
          aws_secretsmanager_secret.redis_password.arn,
          aws_secretsmanager_secret.jwt_secret.arn,
          aws_secretsmanager_secret.api_keys.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.secrets_access.name
  policy_arn = aws_iam_policy.secrets_access.arn
}