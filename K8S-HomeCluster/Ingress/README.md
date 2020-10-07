

## Expand pivs for default account:
    - kubectl create clusterrolebinding --user system:serviceaccount:kube-system:default kube-system-cluster-admin --clusterrole cluster-admin

## Set LoadBalancer and external port:

    - kubectl patch svc SERVICENAME -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.0.X"]}}'


## Get Login token for Dashboard:
    - kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token
    - kubectl proxy
    - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login


## OPENFAAS PASSWORD
    - PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
    - http://192.168.1.149:31690/ui/

    - kubectl -n openfaas run \
        --image=grafana/grafana \
        --port=3000  \
        grafana