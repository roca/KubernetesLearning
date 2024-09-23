# [EKS Hands On: ](https://www.udemy.com/course/kubernetes-on-aws-eks-hands-on-guide-for-devs-devops)

## Steps after each sectioh


```bash
source aws/tfvar.env
cd aws/eks
terraform destroy
cd aws/vpc
terraform destroy
```

[Code on Github: https://github.com/devteds/demo-app-bookstore.git](https://github.com/devteds/demo-app-bookstore.git)

## Docker images

``bash
docker pull devteds/demo-bookstore-website
docker pull devteds/demo-bookstore-shopui
docker pull devteds/demo-bookstore-shopapi
```
