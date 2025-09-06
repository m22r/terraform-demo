terraform {
  required_version = "1.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.12.0"
    }
  }
  # ref. https://developer.hashicorp.com/terraform/language/settings/backends/configuration#partial-configuration
  backend "s3" {
    region = "ap-northeast-1"
  }
}

provider "aws" {
  default_tags {
    tags = {
      Environment = var.env
      Terraform   = "true"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = module.eks.cluster_arn
}
