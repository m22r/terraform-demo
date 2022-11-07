variable "env" {
  type        = string
  default     = ""
  description = "Name of environment"
}

variable "vpc_name_suffix" {
  type        = string
  default     = "demo"
  description = "Name to be used on all the resources as identifier"
}

variable "azs" {
  type = list(string)
  default = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d",
  ]
  description = "A list of availability zones names or ids in the region"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using ipv4_netmask_length & ipv4_ipam_pool_id"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "A list of private subnets inside the VPC"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  description = "A list of public subnets inside the VPC"
}

variable "eks_cluster_name_suffix" {
  type        = string
  default     = "demo"
  description = "Name of the EKS cluster"
}

variable "eks_cluster_version" {
  type        = string
  default     = ""
  description = "Kubernetes <major>.<minor> version to use for the EKS cluster (i.e.: 1.22)"
}

variable "eks_cluster_addons" {
  type = map(any)
  default = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with name"
}

variable "eks_fargate_profiles" {
  type = map(any)
  default = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
    kube-system = {
      name = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }
  }
  description = "Map of Fargate Profile definitions to create"
}

variable "eks_additional_aws_auth_roles" {
  type        = list(map(any))
  default     = []
  description = "List of role maps to add to the aws-auth configmap"
}
