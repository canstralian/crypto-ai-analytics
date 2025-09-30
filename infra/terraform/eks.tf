# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.eks_cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "${var.project_name}-${var.environment}-main"

      instance_types = var.eks_node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.eks_min_size
      max_size     = var.eks_max_size
      desired_size = var.eks_desired_size

      # Launch template configuration
      launch_template_name            = "${var.project_name}-${var.environment}-main"
      launch_template_use_name_prefix = true
      launch_template_version         = "$Latest"

      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      # Enable detailed monitoring
      enable_monitoring = var.monitoring_enabled

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      taints = []

      tags = {
        Environment = var.environment
        NodeGroup   = "main"
      }
    }

    # Spot instances for cost optimization
    spot = {
      name = "${var.project_name}-${var.environment}-spot"

      instance_types = var.eks_node_instance_types
      capacity_type  = "SPOT"

      min_size     = 0
      max_size     = var.eks_max_size
      desired_size = 1

      # Launch template configuration
      launch_template_name            = "${var.project_name}-${var.environment}-spot"
      launch_template_use_name_prefix = true
      launch_template_version         = "$Latest"

      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      labels = {
        Environment = var.environment
        NodeGroup   = "spot"
      }

      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]

      tags = {
        Environment = var.environment
        NodeGroup   = "spot"
      }
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks.eks_managed_node_groups["main"].iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = module.eks.eks_managed_node_groups["spot"].iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  tags = {
    Environment = var.environment
  }
}

# Additional security group for EKS nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-nodes"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "owned"
  }
}

# EKS Addons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
  depends_on   = [module.eks]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  depends_on   = [module.eks]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
  depends_on   = [module.eks]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  depends_on   = [module.eks]
}

# OIDC Provider for service accounts
data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-oidc"
  }
}