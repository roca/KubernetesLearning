# [EKS Hands On: ](https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops)

## Steps after each sectioh

Order of startup

```bash
source aws/tfvars.env
startup.sh
```

- Make sure you update the DB_HOST property in the shopapi yamls

```bash
source aws/tfvars.env
aws eks update-kubeconfig --name demo-cluster --region us-east-1 
kubectl get nodes
kubectl apply -f k8s/tools/nginx-ingress-v1.8.1.yml 

kubectl apply -f k8s/shopapi/deploy.yml
kubectl apply -f k8s/shopapi/job-dbmigrate.yml 
kubectl apply -f k8s/shopapi/job-dbseed.yml 
kubectl apply -f k8s/shopapi/service.yml 

kubectl apply -f k8s/shopui 
kubectl apply -f k8s/website 
kubectl apply -f k8s/ingress.yml 
kubectl get pods
```

[Code on Github: https://github.com/devteds/demo-app-bookstore.git](https://github.com/devteds/demo-app-bookstore.git)

## Docker images

```bash
docker pull devteds/demo-bookstore-website
docker pull devteds/demo-bookstore-shopui
docker pull devteds/demo-bookstore-shopapi
```

```bash
terraform output
export DB_ADDRESS=$(terraform output -raw address)
echo $DB_ADDRESS
mysql -u appuser -papppassword -h $DB_ADDRESS
```

```bash
aws eks update-kubeconfig --name demo-cluster --region us-east-1
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx
```

## Bringing things down
Before you bring down the  terraform eks. Delete the ingress

```bash
kubectl delete apply -f k8s/tools/nginx-ingress-v1.8.1.yml
```

This will remove the Load balancer also !!

Order of removal

```bash
source aws/tfvars.env
shutdown.sh
```

