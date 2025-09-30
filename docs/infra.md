# Infrastructure Documentation

## Overview

This Terraform configuration provisions the complete AWS infrastructure for the Crypto-AI Analytics platform, including:

- **VPC**: Virtual Private Cloud with public, private, and database subnets across multiple AZs
- **EKS**: Managed Kubernetes cluster with auto-scaling node groups
- **RDS**: PostgreSQL database with TimescaleDB extension
- **ElastiCache**: Redis cluster for caching and session management
- **S3**: Buckets for application data, ML models, and backups
- **Secrets Manager**: Secure storage for passwords and API keys
- **IAM**: Roles and policies for secure access

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                           VPC                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Public Subnet  │  │  Public Subnet  │  │Public Subnet │ │
│  │      AZ-A       │  │      AZ-B       │  │     AZ-C     │ │
│  │                 │  │                 │  │              │ │
│  │   Load Balancer │  │                 │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Private Subnet  │  │ Private Subnet  │  │Private Subnet│ │
│  │      AZ-A       │  │      AZ-B       │  │     AZ-C     │ │
│  │                 │  │                 │  │              │ │
│  │   EKS Nodes     │  │   EKS Nodes     │  │  EKS Nodes   │ │
│  │   Redis         │  │   Redis         │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │Database Subnet  │  │Database Subnet  │  │Database      │ │
│  │      AZ-A       │  │      AZ-B       │  │Subnet AZ-C   │ │
│  │                 │  │                 │  │              │ │
│  │   RDS Primary   │  │  RDS Standby    │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.5 installed
3. **kubectl** for Kubernetes management
4. **S3 bucket** for Terraform state (create manually first)
5. **DynamoDB table** for state locking (create manually first)

### Initial Setup

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://crypto-ai-analytics-terraform-state --region us-west-2

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name crypto-ai-analytics-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-west-2
```

## Deployment

### 1. Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

### 5. Configure kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name crypto-ai-analytics-production
```

## Components

### VPC and Networking

- **CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24
- **Private Subnets**: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
- **Database Subnets**: 10.0.201.0/24, 10.0.202.0/24, 10.0.203.0/24
- **NAT Gateways**: One per AZ for high availability
- **Flow Logs**: Enabled for security monitoring

### EKS Cluster

- **Version**: 1.28 (configurable)
- **Node Groups**: 
  - Main (on-demand instances)
  - Spot (for cost optimization)
- **Addons**: VPC CNI, CoreDNS, kube-proxy, EBS CSI driver
- **OIDC Provider**: For IAM role assumption

### RDS Database

- **Engine**: PostgreSQL 15.4
- **Extensions**: TimescaleDB for time-series data
- **Storage**: gp3 with auto-scaling
- **Backups**: 7-30 day retention (configurable)
- **Encryption**: At rest and in transit
- **Monitoring**: Performance Insights enabled

### Redis Cache

- **Version**: Redis 7
- **Mode**: Cluster with replication
- **Encryption**: At rest and in transit
- **Authentication**: Password protected
- **Monitoring**: CloudWatch logs for slow queries

### S3 Buckets

1. **app-data**: Application data and user uploads
2. **ml-models**: Machine learning model artifacts
3. **backups**: Database and system backups

### Security

- **Secrets Manager**: Stores database passwords, API keys
- **IAM Roles**: Service accounts with minimal permissions
- **Security Groups**: Least privilege network access
- **Encryption**: All data encrypted at rest and in transit

## Environments

The configuration supports multiple environments (development, staging, production) with different resource sizes:

### Development
- Smaller instance types
- Single AZ deployment
- Minimal backup retention
- No deletion protection

### Staging
- Medium instance types
- Multi-AZ deployment
- Standard backup retention
- Limited deletion protection

### Production
- Large instance types
- Multi-AZ deployment
- Extended backup retention
- Full deletion protection

## Monitoring and Logging

- **CloudWatch**: Logs and metrics collection
- **VPC Flow Logs**: Network traffic monitoring
- **RDS Performance Insights**: Database performance monitoring
- **EKS Control Plane Logs**: Kubernetes audit logs

## Cost Optimization

- **Spot Instances**: For non-critical workloads
- **S3 Lifecycle Policies**: Automatic data archival
- **Right-sizing**: Configurable instance types
- **Auto-scaling**: Dynamic resource adjustment

## Security Best Practices

- **Least Privilege**: Minimal IAM permissions
- **Network Isolation**: Private subnets for workloads
- **Encryption**: All data encrypted
- **Secrets Management**: No hardcoded credentials
- **Security Groups**: Restrictive network rules

## Disaster Recovery

- **Multi-AZ**: High availability across zones
- **Automated Backups**: Regular database snapshots
- **S3 Versioning**: Data protection and recovery
- **Infrastructure as Code**: Rapid environment recreation

## Troubleshooting

### Common Issues

1. **EKS Node Group Creation Fails**
   - Check IAM permissions
   - Verify subnet availability
   - Ensure security group rules

2. **RDS Connection Issues**
   - Verify security group rules
   - Check subnet group configuration
   - Validate parameter group settings

3. **S3 Access Denied**
   - Check IAM role permissions
   - Verify bucket policies
   - Ensure service account annotations

### Useful Commands

```bash
# Check EKS cluster status
aws eks describe-cluster --name crypto-ai-analytics-production

# List RDS instances
aws rds describe-db-instances

# Check S3 buckets
aws s3 ls

# View Secrets Manager secrets
aws secretsmanager list-secrets
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete all resources and data. Ensure backups are taken before destruction.

## Support

For infrastructure issues:
1. Check AWS CloudWatch logs
2. Review Terraform state
3. Validate resource dependencies
4. Consult AWS documentation