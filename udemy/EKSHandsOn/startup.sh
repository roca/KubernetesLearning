#!/bin/bash

source aws/tfvars.env 
$(cd aws/vpc && terraform apply -auto-approve)
$(cd aws/rds-mysql && terraform apply -auto-approve)
$(cd aws/eks && terraform apply -auto-approve) 

# sleep 600

# aws eks update-kubeconfig --name demo-cluster --region us-east-1 
# kubectl get nodes
# kubectl apply -f k8s/tools/nginx-ingress-v1.8.1.yml 

#  kubectl apply -f k8s/shopapi/deploy.yml
#  kubectl apply -f k8s/shopapi/job-dbmigrate.yml 
#  kubectl apply -f k8s/shopapi/job-dbseed.yml 
#  kubectl apply -f k8s/shopapi/service.yml 

# kubectl apply -f k8s/shopui 
# kubectl apply -f k8s/website 
# kubectl apply -f k8s/ingress.yml 
# kubectl get pods