# Devteds Course Materials. Find more at https://www.devteds.com/kubernetes-course-aws-eks-terraform


terraform {

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.4.0"
    }
  }

}

provider "aws" {
  region = var.region
}

variable "region" {
    default = "us-east-1"
    type        = string
}

variable "cluster_name" {
    default = "demo-cluster"
    type        = string
}



# Devteds Course Materials. Find more at https://www.devteds.com 
# K8S Course: https://www.devteds.com/kubernetes-course-aws-eks-terraform
# Course on Udemy: https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops