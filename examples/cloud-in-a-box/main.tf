terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "cloud"
  region = var.aws_region

  access_key = ""
}

provider "aws" {
  region = var.aws_region

  access_key = "access_key"
  secret_key = "secret_key"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    apigateway     = var.localstack_url
    apigatewayv2   = var.localstack_url
    cloudformation = var.localstack_url
    cloudwatch     = var.localstack_url
    cloudwatchlogs = var.localstack_url
    dynamodb       = var.localstack_url
    ec2            = var.localstack_url
    es             = var.localstack_url
    eks            = var.localstack_url
    elasticache    = var.localstack_url
    firehose       = var.localstack_url
    iam            = var.localstack_url
    kinesis        = var.localstack_url
    kms            = var.localstack_url
    lambda         = var.localstack_url
    rds            = var.localstack_url
    redshift       = var.localstack_url
    route53        = var.localstack_url
    s3             = var.localstack_url
    secretsmanager = var.localstack_url
    ses            = var.localstack_url
    sns            = var.localstack_url
    sqs            = var.localstack_url
    ssm            = var.localstack_url
    stepfunctions  = var.localstack_url
    sts            = var.localstack_url
  }
}

data "aws_availability_zones" "available" {
  provider = aws
}

locals {
  cluster_name = "terraform-testing-${random_string.suffix.result}"

  cidr = "10.0.0.0/16"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # this starting CIDR + 8 "newbits" yields subnets like 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, ...
  private_cidr_start = "10.0.0.0/16"

  # this starting CIDR + 6 "newbits" yields subnets like 10.0.128.0/24, 10.0.129.0/24, 10.0.130.0/24, ...
  public_cidr_start = "10.0.128.0/18"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  providers = {
    aws = aws
  }

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "terraform-testing"

  azs             = local.azs
  cidr            = local.cidr
  private_subnets = cidrsubnets(local.private_cidr_start, [for az in local.azs : 8]...)
  public_subnets  = cidrsubnets(local.public_cidr_start, [for az in local.azs : 6]...)

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  providers = {
    aws = aws
  }

  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    pool = {
      name = "pool"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 6
      desired_size = 3
    }
  }
}