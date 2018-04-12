---

## Cluster resiliency

In this lab you will simulate one failure scenario - worker virtual machine
shutdown.

---

### Set up simple monitoring

+++

In a separate terminal run 

```
watch -n 3 gcloud compute instances list
```

+++

In a separate terminal run

```
watch -n 3 kubectl get nodes
```

+++

In a separate terminal run

```
watch -n kubectl get pods
```

---

### Simulate worker failure

Terminate worker virtual machine from google console

```
gcloud compute instances delete k8s-worker
```

+++

Watch changes in the opened terminals

---

### Simulate master failure

List pods to make sure the API is working now

```
kubectl list pods
```

+++

Shutdown one of the controller vms

```
gcloud compute instances delete k8s-controller
```

+++

List pods to make sure the API is still working

```
kubectl list pods
```

+++

Load balancer in front of k8s cluster detects master failure and stops sending
traffic to this instance

+++

etcd cluster re-elects a new leader providing consistent storage for the rest of
the cluster

+++

it is the responsibility of operator to re-create the master vm. Or one can use
vm pools feature

