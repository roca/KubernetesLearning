#!/usr/local/bin/bash

source aws/tfvars.env \
$(cd aws/vpc && terraform apply -auto-approve) \
$(cd aws/rds-mysql && terraform apply -auto-approve) \
$(cd aws/eks && terraform apply -auto-approve) \
aws eks update-kubeconfig --name demo-cluster --region us-east-1
kubectl get nodes