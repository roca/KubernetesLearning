---

## Managing application dependencies with Helm

Helm is a package manager for Kubernetes. Using Helm one can deploy apps and
Helm will resolve and install dependencies automatically. Helm packages are
called _charts_.

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

- Local chart development
- Managing repositories
- Sending charts to be installed
- Asking for information about releases
- Requesting upgrading or uninstalling of existing releases

+++

### Tiller server

- Listening for incoming requests from the Helm client
- Combining a chart and configuration to build a release
- Installing charts into Kubernetes, and then tracking the subsequent release
- Upgrading and uninstalling charts by interacting with Kubernetes

---

### Install the client

```
brew install kubernetes-helm
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

