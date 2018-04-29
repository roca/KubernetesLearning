---

## Monitoring

---

Heapster is the monitoring framework build for Kubernetes that gathers resource
usage and health data from the nodes and stores them in a pluggable backend.
These metrics can be used for troubleshooting and capacity planning.

---

Heapster:

- runs as a pod in the cluster
- discovers all nodes in the cluster
- queries usage information from the nodes’ Kubelets

+++

The Kubelet itself fetches the data from cAdvisor

+++

- Heapster groups the information by pod along with the relevant labels
- This data is then pushed to a configurable backend
- Most popular storage backend is InfluxDB
- Metrics may be visualised with Grafana

---

### Overall architecture

![](https://d33wubrfki0l68.cloudfront.net/a5c0d5e887a336fb0c686b3a6c436b21d51588a4/8e530/images/docs/monitoring-architecture.png)

---

### cAdvisor

cAdvisor is an open source container resource usage and performance analysis agent. It is purpose-built for containers and supports Docker containers natively.

+++

cAdvisor auto-discovers all containers in the machine and collects CPU, memory,
filesystem, and network usage statistics. 

+++

cAdvisor also provides the overall machine usage by analyzing the ‘root’ container on the machine.

---

### InfluxDB

- InfluxDB exposes an easy to use API to write and fetch time series data
- runs in Pods
- The pod exposes itself as a Kubernetes service which is how Heapster discovers it

---

### Grafana

- provides visual interface for metrics
- runs in Pods
- The pod exposes itself as a Kubernetes service which is how Heapster discovers it

---

### Deploying Heapster to k8s cluster

In this excercise you will deploy Heapster, Grafana and InfluxDB.

---

### Clone Heapster repo

```
git clone https://github.com/kubernetes/heapster.git
```

---

### Create InfluxDB deployment

```
kubectl create -f deploy/kube-config/influxdb/influxdb.yaml
```

---

### Deploy Heapster

```
kubectl create -f deploy/kube-config/rbac/heapster-rbac.yaml
kubectl create -f deploy/kube-config/influxdb/heapster.yaml
```

---

### Deploy Grafana

```
kubectl create -f deploy/kube-config/influxdb/grafana.yaml
```

---

### Connect to Grafana dashboard

Grafana web interface will be exposed using load balancer.

+++

To find out the lb IP and port run 

```
kubectl describe service monitoring-grafana -n kube-system
```

---

### Useful Links

- [Monitoring cluster health with Heapster](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
- [Heapster deployment guide](https://github.com/kubernetes/heapster)

