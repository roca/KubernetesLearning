# install kubefed

## Linux
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/kubernetes-client-linux-amd64.tar.gz
tar -xzvf kubernetes-client-linux-amd64.tar.gz

## OS X
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.1/kubernetes-client-darwin-amd64.tar.gz
tar -xzvf kubernetes-client-darwin-amd64.tar.gz

## Windows
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/kubernetes-client-windows-amd64.tar.gz
tar -xzvf kubernetes-client-windows-amd64.tar.gz

# setup the clusters

Replace desertfoxdev.org with your domain

```
kops create cluster --name=kubernetes.desertfoxdev.org --state=s3://cluster1.k8s.local --zones=us-east-1a --node-count=2 --node-size=t2.small --master-size=t2.small --dns-zone=kubernetes.desertfoxdev.org
kops create cluster --name=kubernetes-2.desertfoxdev.org --state=s3://cluster1.k8s.local --zones=us-west-1c --node-count=2 --node-size=t2.small --master-size=t2.small --dns-zone=kubernetes-2.desertfoxdev.org
kops update cluster kubernetes.desertfoxdev.org --state=s3://cluster1.k8s.local --yes
kops update cluster kubernetes-2.desertfoxdev.org --state=s3://cluster1.k8s.local --yes
```

# initialize federation
kubefed init federated --host-cluster-context=kubernetes.desertfoxdev.org --dns-provider="aws-route53" --dns-zone-name="federated.desertfoxdev.org."

# ns records for federated.desertfoxdev.org
ns-658.awsdns-18.net.
ns-277.awsdns-34.com.
ns-1772.awsdns-29.co.uk.
ns-1424.awsdns-50.org.

# delete
kubectl delete ns federation-system --context=kubernetes.desertfoxdev.org

# join a cluster
kubectl config use-context federated # important, if you don't switch, the next command might fail with an API not found error
kubefed join kubernetes-2 --host-cluster-context=kubernetes.desertfoxdev.org --cluster-context=kubernetes-2.desertfoxdev.org
kubefed join kubernetes-1 --host-cluster-context=kubernetes.desertfoxdev.org --cluster-context=kubernetes.desertfoxdev.org
kubectl create namespace default --context=federated

