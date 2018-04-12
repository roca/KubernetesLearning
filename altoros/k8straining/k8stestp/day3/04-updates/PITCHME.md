---

## Cluster Updates

Cluster update mechanism depends heavily on the tool one uses to manage the
cluster. In this lab we will discuss the upgrade process without specifying the
concrete method.

---

### Assumption: different versions of system components can work in a single cluster

+++

In general it is true but if not for your case, then there are two options
available:

1. Use multiple clusters and upgrade one cluster at a time
2. Acceept downtime during upgrade

---

### Upgrading nodes one by one

Evict all the components from the node so it can be gracefully terminated

```
kubectl drain <node name>
```

+++

When the command returns without an error one can terminate the virtual
machine from the cloud console.

+++

Now one starts a new vm, installs new version of system components and connects
the node to the cluster

+++

After all the nodes are upgraded the cluster is upgraded

---

### Bare metal installation

For bare metal installation one can't terminate the machine.

+++

After upgrading machine to the new software version run 

```
kubectl uncordon <node name>
```

### Parallel upgrade

One can run several `kubectl drain` commands in parallel for increased speed of
upgrade.

+++

Upgrade `masters` one-by-one only

+++

Advice application owners to specify `PodDisruptionBudgets` for their
applications to meet app availability SLOs during the upgrade

+++

Ensure the cluster has capacity to evict pods at every point in time - add new
nodes before shutting draining the old ones.

---

### PodDisruptionBudgets

Kubernetes separates roles of the application owner and cluster owner.

+++

Application owner can specify for their app with 3 replicas

```
minAvailable: 2
```

that means 2 replicas must be always availble.

+++

Now if cluster owner drains two nodes at the same time the first node returns
`OK` and the second fails until the thrid replica is running somewhere else.

---

### Useful links

kubeadm k8s cluster upgrade:
  https://kubernetes.io/docs/tasks/administer-cluster/kubeadm-upgrade-1-8/

kubespray cluster upgrade:
  https://github.com/kubernetes-incubator/kubespray/blob/master/docs/upgrades.md

updates on GKE:
  https://medium.com/retailmenot-engineering/zero-downtime-kubernetes-cluster-upgrades-aab4cac943d2

