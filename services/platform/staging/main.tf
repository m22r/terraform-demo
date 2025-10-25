locals {
  kubectl_minor_version = replace(trim(yamldecode(file("${path.root}/../../../aqua.yaml")).packages[1].version, "v"), "/\\.\\d*$/", "")
  eks_cluster_version   = var.eks_cluster_version != "" ? var.eks_cluster_version : local.kubectl_minor_version
}

#tfsec:ignore:aws-ec2-no-public-ip-subnet
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs false positive
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.4.0"

  name = "${var.env}-${var.vpc_name_suffix}"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = true
}

data "aws_iam_role" "admin" {
  name = "admin"
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
#tfsec:ignore:aws-eks-no-public-cluster-access
#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.6.1"

  cluster_name    = "${var.env}-${var.eks_cluster_name_suffix}"
  cluster_version = local.eks_cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = var.eks_cluster_addons

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  create_kms_key = true
  kms_key_administrators = [
    data.aws_iam_role.admin.arn,
  ]
  kms_key_users = [
    data.aws_iam_role.admin.arn,
  ]

  cluster_encryption_config = [{
    resources = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Fargate Profile(s)
  fargate_profiles = var.eks_fargate_profiles

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = concat([
    {
      rolearn  = data.aws_iam_role.admin.arn
      username = data.aws_iam_role.admin.name
      groups   = ["system:masters"]
    },
  ], var.eks_additional_aws_auth_roles)
}
