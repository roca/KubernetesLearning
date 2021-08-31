https://raspberrytips.com/run-raspberry-in-virtual-machine/


### Setup of master node
```
sudo kubeadm reset
sudo kubeadm init --apiserver-advertise-address=192.168.1.149 --pod-network-cidr=10.244.0.0/16
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Setup of Flannel net working
```
curl -sSL https://rawgit.com/coreos/flannel/v0.13.0/Documentation/kube-flannel.yml | kubectl create -f -
```


### Kubernetes dashboard
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
```
##### Get token for signin
```
 kubectl describe  <secret-name> -n <namespace>

 kubectl proxy
 http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
 ```