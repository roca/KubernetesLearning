# Devteds Course Materials. Find more at https://www.devteds.com/kubernetes-course-aws-eks-terraform


data "aws_availability_zones" "available" {}

locals {
  name            = var.cluster_name
  region          = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    DevtedsStack      = local.name
    DevtedsStackName  = "vpc"
    DevtedsOrg        = "Devteds Courses"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]
  map_public_ip_on_launch = true

  # enable_ipv6                     = true
  # create_egress_only_igw          = true

  # public_subnet_ipv6_prefixes  = [0, 1, 2]
  # private_subnet_ipv6_prefixes = [3, 4, 5]
  # intra_subnet_ipv6_prefixes   = [6, 7, 8]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}


# Devteds Course Materials. Find more at https://www.devteds.com 
# K8S Course: https://www.devteds.com/kubernetes-course-aws-eks-terraform
# Course on Udemy: https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops