

## Expand pivs:
    - kubectl create clusterrolebinding --user system:serviceaccount:kube-system:default kube-system-cluster-admin --clusterrole cluster-admin

## Set LoadBalancer and external port:

    - kubectl patch svc SERVICENAME -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.0.X"]}}'


## Get Login token for FDashboard: i
    - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

    - kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token

## OPENFAAS
 - PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)