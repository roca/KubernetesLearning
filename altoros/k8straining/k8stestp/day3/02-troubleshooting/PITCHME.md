---

## Troubleshooting k8s clusters

---

### List nodes

Verify that all the nodes are correctly registered in the cluster and in the
<span style='color:green'>Ready</span> state.

```
kubectl get nodes
```

---

### Check the logs on master nodes

Log into the master vm

```
gcloud compute ssh k8s-master
```

+++

- /var/log/kube-apiserver.log - API Server, responsible for serving the API
- /var/log/kube-scheduler.log - Scheduler, responsible for making scheduling decisions
- /var/log/kube-controller-manager.log - Controller that manages replication controllers

---

### Check the logs on worker nodes

Log into the worker vm

```
gcloud compute ssh k8s-worker
```

+++

- /var/log/kubelet.log - Kubelet, responsible for running containers on the node
- /var/log/kube-proxy.log - Kube Proxy, responsible for service load balancing

---

### Typical cluster failure modes

---

### Apiserver VM shutdown or apiserver crashing 

- unable to stop, update, or start new pods, services, replication controller
- existing pods and services should continue to work normally, unless they depend on the Kubernetes API

+++

Mitigation: Use IaaS provider’s automatic VM restarting feature for IaaS VMs

+++

Mitigation: Use high-availability configuration

---

### Individual node (VM or physical machine) shuts down 

- pods on that Node stop running

+++

Mitifation: use replication controller and services in front of pods

---

### Network partition

- partition A thinks the nodes in partition B are down; partition B thinks the apiserver is down. (Assuming the master VM ends up in partition A.)

---

### Cluster operator error 

- loss of pods, services, etc
- lost of apiserver backing store
- users unable to read API
- etc.

---

Using multiple independent cluster one can mitigate all the described failure
modes in case no risky changes are applied to all the clusters at once.

