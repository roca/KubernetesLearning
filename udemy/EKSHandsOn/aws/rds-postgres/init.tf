# Devteds Course Materials. Find more at https://www.devteds.com/kubernetes-course-aws-eks-terraform


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }

  required_version = ">= 0.14"
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

variable "apidb_user" { }

variable "apidb_pass" { }




# Devteds Course Materials. Find more at https://www.devteds.com 
# K8S Course: https://www.devteds.com/kubernetes-course-aws-eks-terraform
# Course on Udemy: https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops