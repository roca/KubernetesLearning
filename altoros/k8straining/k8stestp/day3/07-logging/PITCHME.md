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

