#!/usr/local/bin/bash

source aws/tfvars.env
kubectl delete -f k8s/ingress.yml
kubectl delete -f k8s/shopapi
kubectl delete -f k8s/website
kubectl delete -f k8s/tools/nginx-ingress-v1.8.1.yml

$(cd aws/eks && terraform destroy -auto-approve) \
$(cd aws/rds-mysql && terraform destroy -auto-approve) \
$(cd aws/vpc && terraform destroy -auto-approve)