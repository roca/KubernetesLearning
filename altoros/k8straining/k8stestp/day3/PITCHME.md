---


### HELM

+++

Helm is a package manager for Kubernetes. With Helm you can deploy apps including
dependencies. Helm packages are called _charts_.

+++

1. The chart is a bundle of information necessary to create an instance of a Kubernetes application.
1. The config contains configuration information that can be merged into a packaged chart to create a releasable object.
1. A release is a running instance of a chart, combined with a specific config.

---

### Helm architecture

- helm client
- tiller server

+++

### Helm client

- You can Manage your repositories
- deploy charts 
- Query the state of a release
- upgrade or uninstall a release

+++

### Tiller server

- Listens for incoming requests
- Merges a chart and configuration to build a release
- Installs charts into Kubernetes
- Upgrades or uninstall charts

---

### Install the client

```
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-rc3-linux-amd64.tar.gz
tar xvfz helm*.tar.gz linux-amd64/helm
mv linux-amd64/helm /usr/local/bin/
chmod ug+x /usr/local/bin/helm 
```

---

### Install the Tiller server

```
helm init
```

+++

This commands initializes the local cli and also installs Tiller to the
Kubernetes cluster

---

### Search for chart

```
helm repo update
helm search mysql
```

+++

Inspect the deployed release

```
helm inspect stable/mysql
```

---

### Install release

```shell
$ helm install stable/mysql
Released smiling-penguin
```

+++

List deployed releases

```
$ helm ls
NAME           	VERSION	 UPDATED                       	STATUS         	CHART
smiling-penguin	 1      	Wed Sep 28 12:59:46 2016      	DEPLOYED       	mysql-0.1.0
```

---

### Uninstall a release

```shell
$ helm delete smiling-penguin
Removed smiling-penguin
```

+++

```
$ helm status smiling-penguin
Status: DELETED
...
```

---
### Helm documentation

https://docs.helm.sh/

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
gcloud compute ssh controller-0
```

+++

- /var/log/kube-apiserver.log - API Server, responsible for serving the API
- /var/log/kube-scheduler.log - Scheduler, responsible for making scheduling decisions
- /var/log/kube-controller-manager.log - Controller that manages replication controllers

---

### Check the logs on worker nodes

Log into the worker vm

```
gcloud compute ssh worker-0
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

Mitigation 1: Use IaaS provider’s automatic VM restarting feature for IaaS VMs

+++

Mitigation 2: Use high-availability configuration

---

### Individual node (VM or physical machine) shuts down 

- pods on that Node stop running

+++

Mitigation: use replication controller and services in front of pods

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
`OK` and the second fails until the third replica is running somewhere else.

---

### Useful links

kubeadm k8s cluster upgrade:
  https://kubernetes.io/docs/tasks/administer-cluster/kubeadm-upgrade-1-8/

kubespray cluster upgrade:
  https://github.com/kubernetes-incubator/kubespray/blob/master/docs/upgrades.md

updates on GKE:
  https://medium.com/retailmenot-engineering/zero-downtime-kubernetes-cluster-upgrades-aab4cac943d2

---

## User management

There are two types of user accounts in Kubernetes:

1. Service accounts
1. Normal users

+++

Service are managed by Kubernetes and allow processes access cluster API

+++

Normal user accounts are assumed to be managed by an outside independent service

---

### Authentication Strategies

---

### X509 Client Certs

Client provides a certificate that is signed by certification authority (CA)
trusted by API server. `CN` attribute specifies the user name and `O` attribute
specifies the user group.

+++

Example CSR for user `jbeda` belonging to groups `app1` and `app2`

```
openssl req -new -key jbeda.pem -out jbeda-csr.pem -subj "/CN=jbeda/O=app1/O=app2"
```

---

### Static Token File

Server reads client tokens from the plain text file on the local volume or NFS
share.

```
token,user,uid,"group1,group2,group3"
```

+++

Client puts token to the headers of each requests

```
Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269
```

---

### Static Password File

Username and passwords for the Basic HTTP authentication are stored in the plain
text file

```
password,user,uid,"group1,group2,group3"
```

---

### External Integration

Kubernetes client `kubectl` may be integrated with external identity provider
that supports [OpenID Connect](https://openid.net/connect/) flavor of OAuth2

+++

### Public provider examples

- [Google Cloud](https://developers.google.com/identity/protocols/OpenIDConnect#authenticatingtheuser)
- [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-openid-connect-code)

+++

### Private provider examples

- [CoreOS dex](https://github.com/coreos/dex)
- [Keycloack](https://github.com/keycloak/keycloak)
- [Cloud Foundry UAA](https://github.com/cloudfoundry/uaa)

+++

![](https://d33wubrfki0l68.cloudfront.net/d65bee40cabcf886c89d1015334555540d38f12e/c6a46/images/docs/admin/k8s_oidc_login.svg)

+++

### Authentication scenario

1. Login to your identity provider
1. Your identity provider will provide you with an `access_token`, `id_token` and a
`refresh_token`
1. When using kubectl, use your `id_token` with the --token flag or add it directly to your kubeconfig
1. kubectl sends your `id_token` in a header called Authorization to the API server

+++

1. The API server will make sure the JWT signature is valid by checking against the certificate named in the configuration
1. Check to make sure the `id_token` hasn’t expired
1. Make sure the user is authorized
1. Once authorized the API server returns a response to kubectl
1. kubectl provides feedback to the user

+++

Note that Kuberenetes doesn't need to `phone home` while verifying `id_token` -
all the information included in this token and signed by identity provider. This
makes auth solution scalable and stateless.

---

### Useful information

https://kubernetes.io/docs/admin/authentication/

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

---

## Logging in Kubernetes

---

In this lab we will discuss possible logging architectures

---

### Logging at the node level

![](https://d33wubrfki0l68.cloudfront.net/59b1aae2adcfe4f06270b99a2789012ed64bec1f/4d0ad/images/docs/user-guide/logging/logging-node-level.png)

+++

Everything a containerized application writes to stdout and stderr is handled and redirected somewhere by a container engine

Docker container engine redirects those two streams to a logging driver, which is configured in Kubernetes to write to a file in json format

---

### Using a node logging agent

![](https://d33wubrfki0l68.cloudfront.net/2585cf9757d316b9030cf36d6a4e6b8ea7eedf5a/1509f/images/docs/user-guide/logging/logging-with-node-agent.png)

+++

- the logging agent is a dedicated tool that exposes logs or pushes logs to a backend
- Commonly, the logging agent is a container that has access to a directory with log files from all of the application containers on that node
- it’s common to implement it as either a DaemonSet replica

---

### Using a sidecar container with the logging agent

![](https://d33wubrfki0l68.cloudfront.net/c51467e219320fdd46ab1acb40867b79a58d37af/b5414/images/docs/user-guide/logging/logging-with-streaming-sidecar.png)

+++

- The sidecar containers read logs from a file, a socket, or the journald
- Each individual sidecar container prints log to its own stdout or stderr stream

---

### Exposing logs directly from the application

![](https://d33wubrfki0l68.cloudfront.net/0b4444914e56a3049a54c16b44f1a6619c0b198e/260e4/images/docs/user-guide/logging/logging-from-application.png)

---

### Tutorials on setting ELK cluster on Kuberenetes

1. [EFK stack example](https://github.com/kayrus/elk-kubernetes)
1. [Tutorial on setting EFK](https://logz.io/blog/kubernetes-log-analysis/)

Note:

Logging with Elasticsearch: 
  https://kubernetes.io/docs/tasks/debug-application-cluster/logging-elasticsearch-kibana/

Logging architecture:
  https://kubernetes.io/docs/concepts/cluster-administration/logging/

Logging with Stackdriver:
  https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/

Discussion on loggin methods in k8s:
  https://github.com/kubernetes/kubernetes/issues/24677

Streaming logs from the container:
  http://kubernetesbyexample.com/logging/

---
