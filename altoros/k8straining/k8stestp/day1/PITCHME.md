

```bash
$ whoami
```

+++

## Andres Lucas Garcia Fiorini

* I have 20+ years of experience in the IT industry
* I work as a DevOps Engineer at Altoros Argentina
* I love the C programming language and Unix/Linux in general
* I have 4 years working with cloud technologies
* I play the Violin

+++

## Konstantin Burtsev

* I have 12+ years of experience in IT industry and Unix Systems
* I have 2+ years of experience in Cloud Technologies
* I work as a DevOps Engineer and Cloudfoundry Architect at Altoros Belarus
* I like troubleshooting and root cause analysis
* I ride Mountain bike

--- 
 
[https://goo.gl/isNERN](https://goo.gl/isNERN)

[https://github.com/andyfiorini/k8stestp.git](https://github.com/andyfiorini/k8stestp.git)

---

### Prerequisites

####  Option 1

1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for your platform
1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 
1. Install [minikube](https://github.com/kubernetes/minikube/releases)
1. Run `minikube start` to create your own local kubernetes cluster.

####  Option 2

1. Ask the Trainer for Temporary Credentials (limited)

---

### External Resources

The material for this course is based on the following sources:

1. [Kubernetes by Example](https://github.com/openshift-evangelists/kbe)
1. [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
1. [Official Kubernetes Documentation](https://kubernetes.io/docs/home/)

--- 
 
## Kubernetes Overview

---

## Key Features

- Container scheduling
- Horizontal scaling
- Container replication
- Rolling updates
- Labels everywhere

+++

- Volume management
- Self-healing
- Service discovery and load balancing
- Secret and configuration management
- Supports batch jobs

Note:

1. Automatically mount the storage type you need, from local storage to public cloud provider such as GCP or AWS, or a network file sytems like NFS, iSCSI, Gluster, Ceph, Cinder, or Flocker.

2. There is no need to use an external mechanism for service discovery. Kubernetes gives to each container his own IP addresses. DNS resolution is available for one or more containers, and can load-balance across them.

3. Deploy and update secrets and application configuration without rebuilding your image and without exposing secrets in your stack configuration.

4. In addition to services, Kubernetes can manage your batch and CI workloads, replacing containers that fail, if desired.

---

### Other features

- Does not dictate which application frameworks you should use
- Does not restrict the set of supported runtimes (for example, Java, Python, Ruby)

+++

### K8s Does not provide:

- Middleware (e.g., brokers)
- Data-processing frameworks (for example, Spark) 
- Databases (e.g., mysql, postgresql) 
- Marketplace

+++

Does not deploy source code and does not build your application

---

### Common Use Cases

- Stateless microservices deployment
- Statefull service deployment

+++

### Special Use Cases

- App review lab: deploy app version on a new pull request
- CI/CD: run builds, unit and integration tests
- Analisys: batch task to generate report based on data

---

### Comparison to Cloud Foundry

- Runs 12-factor apps
- Can deploy source code
- Virtual machines management with BOSH
- User management included
- Contains a services marketplace

---

### Kubernetes architecture

![](https://s3.eu-central-1.amazonaws.com/altoros-public-images/k8s-nodes.png)

+++

### Master node

- schedules containers to worker nodes
- checks health of containers
- runs cluster API

+++

### Worker node

- run applications in containers
- perform inner load balancing

---

### Components

+++

![](https://s3.eu-central-1.amazonaws.com/altoros-public-images/k8s-components.png)

+++

- <span style='color: red'>kubelet</span> is an agent that runs pods on nodes
- <span style='color: red'>kube-proxy</span> is running on each worker node and provides service load balancing
- <span style='color: red'>kube-dns</span>  provides service discovery for pods

+++

- <span style='color: red'>etcd</span> is the backing data store for Kubernetes
- <span style='color: red'>Kubernetes dashboard</span>  is UI for cluster operations
- <span style='color: red'>Controller</span>  abstracts interactions with cloud provider
- <span style='color: red'>Scheduler</span>  selects node for new pods


--- 
 
## Pods

---

A pod is one or more containers running in k8s.  They usually run on the same network.

+++

A pod is the basic unit of deployment in Kubernetes.  

---

### Exercise: 

Launch a pod using the mhausenblas/simpleservice container image

```bash
$ kubectl run sise --image=mhausenblas/simpleservice:0.5.0 --port=9876
```

+++

We can now see that the pod is running:

```bash
$ kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
sise-3210265840-k705b     1/1       Running   0          1m

$ kubectl describe pod sise-3210265840-k705b | grep IP:
IP:                     172.17.0.3
```

+++

The container is accessible via the pod IP `172.17.0.3`,
we can find this address in the `kubectl describe` command output:

+++

```bash
[cluster] $ curl 172.17.0.3:9876/info
{"host": "172.17.0.3:9876", "version": "0.5.0", "from": "172.17.0.1"}
```

+++

Note that `kubectl run` creates a deployment, in order to
delete the pod we need to execute `kubectl delete deployment sise`.

---

### Launch a pod using the following configuration file

You can also create a pod from a configuration file

+++?code=src/pods/pod.yaml

+++

```bash
$ kubectl create -f src/pods/pod.yaml

$ kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
twocontainers             2/2       Running   0          7s
```

+++

Now we can exec into the `CentOS` container and access the `simpleservice`
on localhost:

```bash
$ kubectl exec twocontainers -c shell -i -t -- bash
[root@twocontainers /]# curl -s localhost:9876/info
{"host": "localhost:9876", "version": "0.5.0", "from": "127.0.0.1"}
```

+++

Specify the `resources` field in the pod to influence how much CPU and/or RAM a
container in a [pod](src/pods/constraint-pod.yaml)
can use (here: `64MB` of RAM and `0.5` CPUs):

+++?code=src/pods/constraint-pod.yaml

+++

```bash
$ kubectl create -f src/pods/constraint-pod.yaml

$ kubectl describe pod constraintpod
...
Containers:
  sise:
    ...
    Limits:
      cpu:      500m
      memory:   64Mi
    Requests:
      cpu:      500m
      memory:   64Mi
...
```

---

### Clean Up

To remove all the pods created, just run:

```bash
$ kubectl delete pod twocontainers

$ kubectl delete pod constraintpod
```

---

### Exercise 

1. Create a configuration file that can deploy [nginx](https://hub.docker.com/_/nginx/) docker image as a pod.   
1. Create a deployment.
1. Access kubernetes host using minikube ssh command.
1. Check that nginx is running and listening in port `80`. You can use `curl --head` command to do this.

--- 
 
## Deployments

---
 
A deployment controller is a declarative ** update ** for pods and replica sets.  It gives you fine-grained
control over how and when a new pod version is rolled out as well as rolled back
to a previous state.

---

In this step, we will create a [deployment](src/deployments/d09.yaml)
with the name `sise-deploy`. This deployment will start and maintain up two replicas of a pod as well as a replica set

+++?code=src/deployments/d09.yaml

+++

```bash
$ kubectl create -f src/deployments/d09.yaml
```

+++

You can see the deployment, the replica set and the pods it looks after like so

```bash
$ kubectl get deploy
NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
sise-deploy   2         2         2            2           10s

$ kubectl get rs
NAME                     DESIRED   CURRENT   READY     AGE
sise-deploy-3513442901   2         2         2         19s

$ kubectl get pods
NAME                           READY     STATUS    RESTARTS   AGE
sise-deploy-3513442901-cndsx   1/1       Running   0          25s
sise-deploy-3513442901-sn74v   1/1       Running   0          25s
```

+++

At this point the `sise` containers running in the pods are configured
in version `0.9`.  We need to verify that from within the cluster (using `kubectl describe`
first to get the IP of one of the pods)

+++

```bash
[cluster] $ curl 172.17.0.3:9876/info
{"host": "172.17.0.3:9876", "version": "0.9", "from": "172.17.0.1"}
```

+++

Now we will change  version to `1.0` with a new [deployment](src/deployments/d10.yaml):

+++?code=src/deployments/d10.yaml

+++

```bash
$ kubectl apply -f src/deployments/d10.yaml
deployment "sise-deploy" configured
```

+++

Note that you could have used `kubectl edit deploy/sise-deploy` alternatively to
achieve the same by manually editing the deployment.

+++

What we now see is the rollout of two new pods with the updated version `1.0` as well
as the two old pods with version `0.9` being terminated:

```bash
$ kubectl get pods
NAME                           READY     STATUS        RESTARTS   AGE
sise-deploy-2958877261-nfv28   1/1       Running       0          25s
sise-deploy-2958877261-w024b   1/1       Running       0          25s
sise-deploy-3513442901-cndsx   1/1       Terminating   0          16m
sise-deploy-3513442901-sn74v   1/1       Terminating   0          16m
```

+++

Also, a new replica set has been created by the deployment:

```bash
$ kubectl get rs
NAME                     DESIRED   CURRENT   READY     AGE
sise-deploy-2958877261   2         2         2         4s
sise-deploy-3513442901   0         0         0         24m
```

+++

Note that during the deployment you can check the progress using `kubectl rollout status deploy/sise-deploy`.

+++

To verify that if the new `1.0` version is really available, we execute from
within the cluster (again using `kubectl describe` get the IP of one of the pods):

```bash
[cluster] $ curl 172.17.0.5:9876/info
{"host": "172.17.0.5:9876", "version": "1.0", "from": "172.17.0.1"}
```

+++

A history of all deployments is available via:

```bash
$ kubectl rollout history deploy/sise-deploy
deployments "sise-deploy"
REVISION        CHANGE-CAUSE
1               <none>
2               <none>
```

+++

If there is a problem with the deployment, Kubernetes will automatically roll back to
the previous version, however you can also explicitly roll back to a specific revision,
as in our case to revision 1 (the original pod version):

+++

```bash
$ kubectl rollout undo deploy/sise-deploy --to-revision=1
deployment "sise-deploy" rolled back

$ kubectl rollout history deploy/sise-deploy
deployments "sise-deploy"
REVISION        CHANGE-CAUSE
2               <none>
3               <none>

$ kubectl get pods
NAME                           READY     STATUS    RESTARTS   AGE
sise-deploy-3513442901-ng8fz   1/1       Running   0          1m
sise-deploy-3513442901-s8q4s   1/1       Running   0          1m
```

+++

At this point we're back where we started, with two new pods serving
again version `0.9`.

---

Finally, to clean up, we remove the deployment and with it the replica sets and
pods:

```bash
$ kubectl delete deploy sise-deploy
deployment "sise-deploy" deleted
```

---

See also the [docs](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
for more options on deployments and when they are triggered.

---

### Exercise 

1. Deploy `sise-deploy` again.
1. Navigate into the container and kill the webserver process.
1. Observe whether kubernetes will try to start another container. 

--- 
 
## Health Checks

---

In order to verify if a container is in good shape and ready to serve traffic,
Kubernetes provides health check mechanisms. 

+++

Health checks,
or probes as they are called in Kubernetes, are carried out
by the [kubelet](https://kubernetes.io/docs/admin/kubelet/) to determine when to
restart a container (for `livenessProbe`) and by services to
determine if a pod should receive traffic or not (for `readinessProbe`).

+++

We will focus on HTTP health checks first.

---

### Good pod

In this step we will create a [pod](src/healthz/pod.yaml)
that exposes an endpoint `/health`, answering with a HTTP `200` status code:

+++?code=src/healthz/pod.yaml

+++

```bash
$ kubectl create -f src/healthz/pod.yaml
```

+++

In the pod specification we've defined the following:

```
livenessProbe:
  initialDelaySeconds: 2
  periodSeconds: 5
  httpGet:
    path: /health
    port: 9876
```

+++

This means that Kubernetes will start checking `/health` endpoint in every 5 seconds after waiting 2 seconds for the first check.

+++

If we now look at the pod we can see that it is considered healthy:

```bash
$ kubectl describe pod hc
Name:                   hc
Namespace:              default
Security Policy:        anyuid
Node:                   192.168.99.100/192.168.99.100
Start Time:             Tue, 25 Apr 2017 16:21:11 +0100
Labels:                 <none>
Status:                 Running
...
Events:
  FirstSeen     LastSeen        Count   From                            SubobjectPath           Type            Reason          Message
  ---------     --------        -----   ----                            -------------           --------        ------          -------
  3s            3s              1       {default-scheduler }                                    Normal          Scheduled       Successfully assigned hc to 192.168.99.100
  3s            3s              1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Pulled          Container image "mhausenblas/simpleservice:0.5.0"
already present on machine
  3s            3s              1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Created         Created container with docker id 8a628578d6ad; Security:[seccomp=unconfined]
  2s            2s              1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Started         Started container with docker id 8a628578d6ad
```

---

### Bad pod

We will launch a [bad pod](src/healthz/badpod.yaml),
that is, a pod that has a container that randomly (in the time range 1 to 4 sec)
does not return a 200 code:

+++?code=src/healthz/badpod.yaml

+++

```bash
$ kubectl create -f src/healthz/badpod.yaml
```

+++

Looking at the events of the bad pod, we can see that the health check failed:

```bash
$ kubectl describe pod badpod
...
Events:
  FirstSeen     LastSeen        Count   From                            SubobjectPath           Type            Reason          Message
  ---------     --------        -----   ----                            -------------           --------        ------          -------
  1m            1m              1       {default-scheduler }                                    Normal          Scheduled       Successfully assigned badpod to 192.168.99.100
  1m            1m              1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Created         Created container with docker id 7dd660f04945; Security:[seccomp=unconfined]
  1m            1m              1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Started         Started container with docker id 7dd660f04945
  1m            23s             2       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Pulled          Container image "mhausenblas/simpleservice:0.5.0" already present on machine
  23s           23s             1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Killing         Killing container with docker id 7dd660f04945: pod "badpod_default(53e5c06a-29cb-11e7-b44f-be3e8f4350ff)" container "sise" is unhealthy, it will be killed and re-created.
  23s           23s             1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Created         Created container with docker id ec63dc3edfaa; Security:[seccomp=unconfined]
  23s           23s             1       {kubelet 192.168.99.100}        spec.containers{sise}   Normal          Started         Started container with docker id ec63dc3edfaa
  1m            18s             4       {kubelet 192.168.99.100}        spec.containers{sise}   Warning         Unhealthy       Liveness probe failed: Get http://172.17.0.4:9876/health: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
```

+++

This can also be verified as follows:

```bash
$ kubectl get pods
NAME                      READY     STATUS    RESTARTS   AGE
badpod                    1/1       Running   4          2m
hc                        1/1       Running   0          6m
```

+++

From above you can see that the `badpod` had already been re-launched 4 times,
since the health check failed.

---

### Readiness probe

In addition to a `livenessProbe`, you can also specify a `readinessProbe`, which
can be configured in the same way but has a different use case and semantics:
it's used to check the start-up phase of a container in the pod. 

+++

Imagine a container
that loads some data from external storage such as S3 or a database that needs
to initialize some tables. In this case you want to signal when the container is
ready to serve traffic.

+++

Now we will create a [pod](src/healthz/ready.yaml)
with a `readinessProbe` that kicks in after 10 seconds:

+++?code=src/healthz/ready.yaml

+++

```bash
$ kubectl create -f src/healthz/ready.yaml
```

+++

Looking at the events of the pod, we can see that eventually, the pod is ready
to serve traffic:

```bash
$ kubectl describe pod ready
...
Conditions:                                                                                                                                                               [0/1888]
  Type          Status
  Initialized   True
  Ready         True
  PodScheduled  True
...
```

---

### Clean Up

You can remove all the created pods with:

```bash
$ kubectl delete pod/hc pod/ready pod/badpod
```

---

Learn more about configuring probes, including TCP and command probes, via the
[docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/).

---

### Exercise 

1. Deploy a pod that runs nginx and uses port 80 and root path for healthcheck. Ensure that pod is healthy.
1. Change healthcheck configuration to make pod unhealthy.
1. Observe whether kubernetes tries to restart the unhealthy pod.


--- 
 
## Volumes

---

A Kubernetes volume is essentially a directory accessible to all containers
running in a pod. In contrast to the container-local filesystem, the data in
volumes is preserved across container restarts.

+++

The medium backing a volume and its contents are determined
by the volume type:

+++

- node-local types such as `emptyDir` or `hostPath`
- file-sharing types such as `nfs`
- cloud provider-specific types like `awsElasticBlockStore`, `azureDisk`, or `gcePersistentDisk`
- distributed file system types, for example `glusterfs` or `cephfs`
- special-purpose types like `secret`, `gitRepo`

---

In this step we will create a [pod](src/volumes/pod.yaml)
with two containers that use an `emptyDir` volume to exchange data:

+++?code=src/volumes/pod.yaml

+++

```bash
$ kubectl create -f src/volumes/pod.yaml

$ kubectl describe pod sharevol
Name:                   sharevol
Namespace:              default
...
Volumes:
  xchange:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
```

+++

We first exec into one of the containers in the pod, `c1`, check the volume mount
and generate some data:

```bash
$ kubectl exec sharevol -c c1 -i -t -- bash
[root@sharevol /]# mount | grep xchange
/dev/sda1 on /tmp/xchange type ext4 (rw,relatime,data=ordered)
[root@sharevol /]# echo 'some data' > /tmp/xchange/data
```

+++

When we now exec into `c2`, the second container running in the pod, we can see
the volume mounted at `/tmp/data` and are able to read the data created in the
previous step:

+++

```bash
$ kubectl exec sharevol -c c2 -i -t -- bash
[root@sharevol /]# mount | grep /tmp/data
/dev/sda1 on /tmp/data type ext4 (rw,relatime,data=ordered)
[root@sharevol /]# cat /tmp/data/data
some data
```

---

You can remove the pod with:

```bash
$ kubectl delete pod/sharevol
```

As already described, this will destroy the shared volume and all its contents.

---

### Exercise 

1. Create a pod that runs two containers: the first one should run nginx; the second one sleep command.
1. Create a volume that mounts into `/usr/share/nginx/html` in nginx container and into `/tmp/html` in the second container.
1. Navigate into the second container and create an [html file](https://www.w3schools.com/html/tryit.asp?filename=tryhtml_basic_document) in the `/tmp/html` folder.
1. Ensure that nginx now can return this document. 

--- 
 
## Secrets

---

You do not want sensitive information such as a database password or an
API key kept around in clear text. Secrets provide you with a mechanism
to use such information in a safe and reliable way with the following properties:

+++

- Secrets exist in the context of a namespace
- You can access them via a volume or an environment variable from a container running in a pod
- The secret data on nodes is stored in [tmpfs](https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt) volumes
- A per-secret size limit of 1MB exists
- The API server stores secrets as plaintext in etcd

---

Now we will create a secret `apikey` that holds an API key:

```bash
$ echo -n "A19fh68B001j" > ./apikey.txt

$ kubectl create secret generic apikey --from-file=./apikey.txt
secret "apikey" created

$ kubectl describe secrets/apikey
Name:           apikey
Namespace:      default
Labels:         <none>
Annotations:    <none>

Type:   Opaque

Data
====
apikey.txt:     12 bytes
```

+++

Now let's use the secret in a [pod](src/secrets/pod.yaml)
via a volume:

+++?code=src/secrets/pod.yaml

+++

```bash
$ kubectl create -f src/secrets/pod.yaml
```

+++

If we do kubectl exec into the container we will found the secret mounted at `/tmp/apikey`:

```
$ kubectl exec ** consumesec ** -c shell -i -t -- bash
[root@consumesec /]# mount | grep apikey
tmpfs on /tmp/apikey type tmpfs (ro,relatime)
[root@consumesec /]# cat /tmp/apikey/apikey.txt
A19fh68B001j
```

---

### Clean Up

You can remove both the pod and the secret with

```bash
$ kubectl delete pod/consumesec secret/apikey
```

---

### Exercise 

1. Redeploy `consumesec` pod  
2. Expose a secret using environment variables this time. Further information on [secrets as Environment Variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets) 
3. Navigate into the container and ensure you can see the secret on the Environment Variables.

--- 
 
## Labels

---

Labels are the mechanism you use to organize Kubernetes objects. A label is a key-value
pair with certain [restrictions](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set)
concerning length and allowed values but without any pre-defined meaning.

---

## Labels in pods

In this step we will create a [pod](src/labels/pod.yaml) with a label (`env=development`) in the definition.

+++?code=src/labels/pod.yaml

+++

```bash
$ kubectl create -f src/labels/pod.yaml

$ kubectl get pods --show-labels
NAME       READY     STATUS    RESTARTS   AGE    LABELS
labelex    1/1       Running   0          10m    env=development
```

+++

In above `get pods` command note the `--show-labels` option that output the
labels of an object in an additional column.

+++

You can add a label to the pod as:

```bash
$ kubectl label pods labelex owner=michael

$ kubectl get pods --show-labels
NAME        READY     STATUS    RESTARTS   AGE    LABELS
labelex     1/1       Running   0          16m    env=development,owner=michael
```

+++

We can use labels for filtering a list. For example, to list all the pods labeled as "owner=michael", we can use `--selector` option:

```bash
$ kubectl get pods --selector owner=michael
NAME      READY     STATUS    RESTARTS   AGE
labelex   1/1       Running   0          27m
```

+++

The `--selector` option can be abbreviated to `-l`, so to select pods that are
labelled with `env=development`, do:

```bash
$ kubectl get pods -l env=development
NAME      READY     STATUS    RESTARTS   AGE
labelex   1/1       Running   0          27m
```

---

We will launch [another pod](src/labels/anotherpod.yaml)
with two labels (`env=production` and `owner=michael`):

+++?code=src/labels/anotherpod.yaml

+++

```bash
$ kubectl create -f src/labels/anotherpod.yaml
```

+++

Now, if we list all pods that are either labeled with `env=development` or with
`env=production`:

```bash
$ kubectl get pods -l 'env in (production, development)'
NAME           READY     STATUS    RESTARTS   AGE
labelex        1/1       Running   0          43m
labelexother   1/1       Running   0          3m
```

+++

Other verbs also support label selection, for example, you could
remove both of these pods with:

```bash
$ kubectl delete pods -l 'env in (production, development)'
```

---

Note that labels are not restricted to pods. In fact you can apply them to
all sorts of objects, such as nodes or services.

---

### Exercise 

1. Deploy 3 pods; each one with  different labels: `version=1`, `version=2` and `version=3`.
1. List the pods using selectors, that will return all pods with versions not equal to 3. Refer to the [documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) to review selector syntax.

--- 
 
## Replication controllers

---

A replication controller (RC) is a controller for long-running pods.
An RC will launch a specified number of replicas of a certain pod and keep 
those always running. For example when a node fails or something
goes wrong in a container, the replication controller will start another pod to
replace the failing one.

---

In the next exercise we will create an [RC](src/rcs/rc.yaml)
that will maintain a single replica of a pod:

+++?code=src/rcs/rc.yaml

+++

```bash
$ kubectl create -f src/rcs/rc.yaml
```

+++

You can see the RC and the pod it looks after like so:

```bash
$ kubectl get rc
NAME                DESIRED   CURRENT   READY     AGE
rcex                1         1         1         3m

$ kubectl get pods --show-labels
NAME           READY     STATUS    RESTARTS   AGE    LABELS
rcex-qrv8j     1/1       Running   0          4m     app=sise
```

+++

To scale out, that is, to increase the number of replicas, do:

```bash
$ kubectl scale --replicas=3 rc/rcex

$ kubectl get pods -l app=sise
NAME         READY     STATUS    RESTARTS   AGE
rcex-1rh9r   1/1       Running   0          54s
rcex-lv6xv   1/1       Running   0          54s
rcex-qrv8j   1/1       Running   0          10m

```

---

### Clean Up

Finally, to get rid of the RC and the pods it is supervising, use:

```bash
$ kubectl delete rc rcex
replicationcontroller "rcex" deleted
```

---

Note that, going forward, the RCs are called [replica sets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) (RS), supporting set-based selectors. The RS are already in use in the context of [deployments](/deployments/).


---

### Exercise 

1. Redeploy rcex replication controller.
1. Deploy a new pod with label `app=sise`
1. Observe the number of pods managed by our replication controller.  Look if something changed.

--- 
 
## Services

---

A service provides a stable virtual IP (VIP) address to our pods.

+++

While pods may come and go, services allow clients to consistenly connect to the
containers running in the pods, using the VIP. The `virtual` in VIP means that it is not an actual IP address assigned to a network interface.  The purpose of having VIPs is to forward traffic to one or more pods in our cluster. 

+++

Keeping the mapping between the VIP and the pods up-to-date is the job of [kube-proxy](https://kubernetes.io/docs/admin/kube-proxy/), a process that runs on every node, which queries the API server to learn about new services in the cluster.

---

Let's create a pod supervised by an [RC](src/services/rc.yaml)
and a [service](src/services/svc.yaml)
along with it:

+++?code=src/services/rc.yaml

+++?code=src/services/svc.yaml

+++

```bash
$ kubectl create -f src/services/rc.yaml

$ kubectl create -f src/services/svc.yaml
```

+++

Now we have the supervised pod running:

```bash
$ kubectl get pods -l app=sise
NAME           READY     STATUS    RESTARTS   AGE
rcsise-6nq3k   1/1       Running   0          57s

$ kubectl describe pod rcsise-6nq3k
Name:                   rcsise-6nq3k
Namespace:              default
Security Policy:        restricted
Node:                   localhost/192.168.99.100
Start Time:             Tue, 25 Apr 2017 14:47:45 +0100
Labels:                 app=sise
Status:                 Running
IP:                     172.17.0.3
Controllers:            ReplicationController/rcsise
Containers:
...
```

+++

You can, from within the cluster, access the pod directly via its
assigned IP `172.17.0.3`:

```bash
[cluster] $ curl 172.17.0.3:9876/info
{"host": "172.17.0.3:9876", "version": "0.5.0", "from": "172.17.0.1"}
```

+++

This is however, as mentioned above, not advisable since the IPs assigned
to pods may change. Hence, enter the `simpleservice` we have created:

```bash
$ kubectl get svc
NAME              CLUSTER-IP       EXTERNAL-IP   PORT(S)                   AGE
simpleservice     172.30.228.255   <none>        80/TCP                    5m

$ kubectl describe svc simpleservice
Name:                   simpleservice
Namespace:              default
Labels:                 <none>
Selector:               app=sise
Type:                   ClusterIP
IP:                     172.30.228.255
Port:                   <unset> 80/TCP
Endpoints:              172.17.0.3:9876
Session Affinity:       None
No events.
```

+++

The service keeps track of the pods it forwards traffic to through the label,
in our case `app=sise`.

+++

From within the cluster we can now access `simpleservice` like so:

```bash
[cluster] $ curl 172.30.228.255:80/info
{"host": "172.30.228.255", "version": "0.5.0", "from": "10.0.2.15"}
```

+++

What makes the VIP `172.30.228.255` forward the traffic to the pod?

+++

The answer is: [IPtables](https://wiki.centos.org/HowTos/Network/IPTables),
which is essentially a long list of rules that tells the Linux kernel what to do
with a certain IP package.

+++

Looking at the rules that concern our service (executed on a cluster node) yields:

```bash
[cluster] $ sudo iptables-save | grep simpleservice
-A KUBE-SEP-4SQFZS32ZVMTQEZV -s 172.17.0.3/32 -m comment --comment "default/simpleservice:" -j KUBE-MARK-MASQ
-A KUBE-SEP-4SQFZS32ZVMTQEZV -p tcp -m comment --comment "default/simpleservice:" -m tcp -j DNAT --to-destination 172.17.0.3:9876
-A KUBE-SERVICES -d 172.30.228.255/32 -p tcp -m comment --comment "default/simpleservice: cluster IP" -m tcp --dport 80 -j KUBE-SVC-EZC6WLOVQADP4IAW
-A KUBE-SVC-EZC6WLOVQADP4IAW -m comment --comment "default/simpleservice:" -j KUBE-SEP-4SQFZS32ZVMTQEZV
```

+++

Above you can see the four rules that `kube-proxy` has thankfully added to the
routing table, essentially stating that TCP traffic to `172.30.228.255:80`
should be forwarded to `172.17.0.3:9876`, which is our pod.

---

Let’s now add a second pod by scaling up the RC supervising it:

```bash
$ kubectl scale --replicas=2 rc/rcsise
replicationcontroller "rcsise" scaled

$ kubectl get pods -l app=sise
NAME           READY     STATUS    RESTARTS   AGE
rcsise-6nq3k   1/1       Running   0          15m
rcsise-nv8zm   1/1       Running   0          5s
```

+++

When we now check the relevant parts of the routing table again we notice
the addition of a bunch of IPtables rules:

```bash
[cluster] $ sudo iptables-save | grep simpleservice
-A KUBE-SEP-4SQFZS32ZVMTQEZV -s 172.17.0.3/32 -m comment --comment "default/simpleservice:" -j KUBE-MARK-MASQ
-A KUBE-SEP-4SQFZS32ZVMTQEZV -p tcp -m comment --comment "default/simpleservice:" -m tcp -j DNAT --to-destination 172.17.0.3:9876
-A KUBE-SEP-PXYYII6AHMUWKLYX -s 172.17.0.4/32 -m comment --comment "default/simpleservice:" -j KUBE-MARK-MASQ
-A KUBE-SEP-PXYYII6AHMUWKLYX -p tcp -m comment --comment "default/simpleservice:" -m tcp -j DNAT --to-destination 172.17.0.4:9876
-A KUBE-SERVICES -d 172.30.228.255/32 -p tcp -m comment --comment "default/simpleservice: cluster IP" -m tcp --dport 80 -j KUBE-SVC-EZC6WLOVQADP4IAW
-A KUBE-SVC-EZC6WLOVQADP4IAW -m comment --comment "default/simpleservice:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-4SQFZS32ZVMTQEZV
-A KUBE-SVC-EZC6WLOVQADP4IAW -m comment --comment "default/simpleservice:" -j KUBE-SEP-PXYYII6AHMUWKLYX
```

+++

In above routing table listing we see rules for the newly created pod serving at
`172.17.0.4:9876` as well as an additional rule:

```
-A KUBE-SVC-EZC6WLOVQADP4IAW -m comment --comment "default/simpleservice:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-4SQFZS32ZVMTQEZV
```

+++

This causes the traffic to the service being equally split between our two pods
by invoking the `statistics` module of IPtables.

---

### Clean Up

You can remove all the resources created by doing:

```bash
$ kubectl delete svc simpleservice

$ kubectl delete rc rcsise
```

---

### Exercise 

1. Deploy nginx pod and a service that assignes virtual IP to it.
1. Access nginx by virtual IP.

--- 
 
## Service Discovery

---

Service discovery is the process of figuring out how to connect to a service.
While there is a service discovery option based on [environment
variables](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#environment-variables)
available, the DNS-based service discovery is preferable. 

+++
Note that DNS is a [cluster add-on](https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/dns/README.md)
so make sure your Kubernetes distribution provides one or install it
yourself.

---

Let's create a [service](src/sd/svc.yaml) named
`thesvc` and an [RC](src/sd/rc.yaml) supervising
some pods along with it:

+++?code=src/sd/svc.yaml

+++?code=src/sd/rc.yaml

+++

```bash
$ kubectl create -f src/sd/rc.yaml

$ kubectl create -f src/sd/svc.yaml
```

+++

Now we want to connect to the `thesvc` service from within the cluster, say, from another service.

+++

To simulate this, we create a [jump pod](src/sd/jumpod.yaml)
in the same namespace (`default`, since we didn't specify anything else):

+++?code=src/sd/jumpod.yaml

+++


```bash
$ kubectl create -f src/sd/jumpod.yaml
```

+++

The DNS add-on will make sure that our service `thesvc` is available via the FQDN
`thesvc.default.svc.cluster.local` from other pods in the cluster. Let's try it out:

+++

```bash
$ kubectl exec jumpod -c shell -i -t -- ping thesvc.default.svc.cluster.local
PING thesvc.reshifter.svc.cluster.local (172.30.251.137) 56(84) bytes of data.
...
```

+++

The answer to the `ping` tells us that the service is available via the cluster
IP `172.30.251.137`. We can directly connect to and consume the service (in the same namespace) like so:

 ```bash
 $ kubectl exec jumpod -c shell -i -t -- curl http://thesvc/info
{"host": "thesvc", "version": "0.5.0", "from": "172.17.0.5"}
```

+++

Note that the IP address `172.17.0.5` above is the cluster-internal IP address
of the jump pod.

---

To access a service that is deployed in a different namespace than the one you're
accessing it from, use a FQDN in the from `$SVC.$NAMESPACE.svc.cluster.local`.

+++

Let's see how that works by creating:

1. a [namespace](src/sd/other-ns.yaml) `other`
1. a [service](src/sd/other-svc.yaml) `thesvc` in namespace `other`
1. an [RC](src/sd/other-rc.yaml) supervising the pods, also in namespace `other`

+++?code=src/sd/other-ns.yaml

+++?code=src/sd/other-svc.yaml

+++?code=src/sd/other-rc.yaml

+++


```bash
$ kubectl create -f src/sd/other-ns.yaml

$ kubectl create -f src/sd/other-rc.yaml

$ kubectl create -f src/sd/other-svc.yaml
```

+++

We are now in the position to consume the service `thesvc` in namespace `other` from the
`default` namespace (again via the jump pod):

 ```bash
$ kubectl exec jumpod -c shell -i -t -- curl http://thesvc.other/info
{"host": "thesvc.other", "version": "0.5.0", "from": "172.17.0.5"}
```

---

Summing up, DNS-based service discovery provides a flexible and generic way to
connect to services across the cluster.

---

### Clean Up

You can destroy all the resources created with:

```bash
$ kubectl delete pods jumpod

$ kubectl delete svc thesvc

$ kubectl delete rc rcsise

$ kubectl delete ns other
```

---

### Exercise 

1. Create a pod deployment that consist of nginx container and jumppod contaner. 
1. Make sure that nginx is accessible from jumpod via a DNS name.  (You don't need to create service, you have to access pod by its own DNS name, for details how to do this please reference [official documentation](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pods))

--- 
 
## Environment variables

---

You can set environment variables for containers running in a pod.  Kubernetes exposes certain runtime configuration via environment variables too.

---

Let's launch a [pod](src/envs/pod.yaml)
that we pass an environment variable `SIMPLE_SERVICE_VERSION` with the value `1.0`:

+++?code=src/envs/pod.yaml

+++

```bash
$ kubectl create -f src/envs/pod.yaml

$ kubectl describe pod envs | grep IP:
IP:                     172.17.0.3
```

+++

Now, let's verify from within the cluster if the application running in the pod
has picked up the environment variable `SIMPLE_SERVICE_VERSION`:

```bash
[cluster] $ curl 172.17.0.3:9876/info
{"host": "172.17.0.3:9876", "version": "1.0", "from": "172.17.0.1"}
```

+++

And indeed it has picked up the user-provided environment variable (the default,
response would be `"version": "0.5.0"`).

+++

You can check what environment variables Kubernetes itself provides automatically
(from within the cluster, using a dedicated endpoint that the [app](https://github.com/mhausenblas/simpleservice)
exposes):

+++

```bash
[cluster] $ curl 172.17.0.3:9876/env
{"version": "1.0", "env": "{'HOSTNAME': 'envs', 'DOCKER_REGISTRY_SERVICE_PORT': '5000', 'KUBERNETES_PORT_443_TCP_ADDR': '172.30.0.1', 'ROUTER_PORT_80_TCP_PROTO': 'tcp', 'KUBERNETES_PORT_53_UDP_PROTO': 'udp', 'ROUTER_SERVICE_HOST': '172.30.246.127', 'ROUTER_PORT_1936_TCP_PROTO': 'tcp', 'KUBERNETES_SERVICE_PORT_DNS': '53', 'DOCKER_REGISTRY_PORT_5000_TCP_PORT': '5000', 'PATH': '/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', 'ROUTER_SERVICE_PORT_443_TCP': '443', 'KUBERNETES_PORT_53_TCP': 'tcp://172.30.0.1:53', 'KUBERNETES_SERVICE_PORT': '443', 'ROUTER_PORT_80_TCP_ADDR': '172.30.246.127', 'LANG': 'C.UTF-8', 'KUBERNETES_PORT_53_TCP_ADDR': '172.30.0.1', 'PYTHON_VERSION': '2.7.13', 'KUBERNETES_SERVICE_HOST': '172.30.0.1', 'PYTHON_PIP_VERSION': '9.0.1', 'DOCKER_REGISTRY_PORT_5000_TCP_PROTO': 'tcp', 'REFRESHED_AT': '2017-04-24T13:50', 'ROUTER_PORT_1936_TCP': 'tcp://172.30.246.127:1936', 'KUBERNETES_PORT_53_TCP_PROTO': 'tcp', 'KUBERNETES_PORT_53_TCP_PORT': '53', 'HOME': '/root', 'DOCKER_REGISTRY_SERVICE_HOST': '172.30.1.1', 'GPG_KEY': 'C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF', 'ROUTER_SERVICE_PORT_80_TCP': '80', 'ROUTER_PORT_443_TCP_ADDR': '172.30.246.127', 'ROUTER_PORT_1936_TCP_ADDR': '172.30.246.127', 'ROUTER_SERVICE_PORT': '80', 'ROUTER_PORT_443_TCP_PORT': '443', 'KUBERNETES_SERVICE_PORT_DNS_TCP': '53', 'KUBERNETES_PORT_53_UDP_ADDR': '172.30.0.1', 'KUBERNETES_PORT_53_UDP': 'udp://172.30.0.1:53', 'KUBERNETES_PORT': 'tcp://172.30.0.1:443', 'ROUTER_PORT_1936_TCP_PORT': '1936', 'ROUTER_PORT_80_TCP': 'tcp://172.30.246.127:80', 'KUBERNETES_SERVICE_PORT_HTTPS': '443', 'KUBERNETES_PORT_53_UDP_PORT': '53', 'ROUTER_PORT_80_TCP_PORT': '80', 'ROUTER_PORT': 'tcp://172.30.246.127:80', 'ROUTER_PORT_443_TCP': 'tcp://172.30.246.127:443', 'SIMPLE_SERVICE_VERSION': '1.0', 'ROUTER_PORT_443_TCP_PROTO': 'tcp', 'KUBERNETES_PORT_443_TCP': 'tcp://172.30.0.1:443', 'DOCKER_REGISTRY_PORT_5000_TCP': 'tcp://172.30.1.1:5000', 'DOCKER_REGISTRY_PORT': 'tcp://172.30.1.1:5000', 'KUBERNETES_PORT_443_TCP_PORT': '443', 'ROUTER_SERVICE_PORT_1936_TCP': '1936', 'DOCKER_REGISTRY_PORT_5000_TCP_ADDR': '172.30.1.1', 'DOCKER_REGISTRY_SERVICE_PORT_5000_TCP': '5000', 'KUBERNETES_PORT_443_TCP_PROTO': 'tcp'}"}
```

+++

Alternatively, you can also use `kubectl exec` to connect to the container and list the
environment variables directly, there:

+++

```bash
$ kubectl exec envs -- printenv
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=envs
SIMPLE_SERVICE_VERSION=1.0
KUBERNETES_PORT_53_UDP_ADDR=172.30.0.1
KUBERNETES_PORT_53_TCP_PORT=53
ROUTER_PORT_443_TCP_PROTO=tcp
DOCKER_REGISTRY_PORT_5000_TCP_ADDR=172.30.1.1
KUBERNETES_SERVICE_PORT_DNS_TCP=53
ROUTER_PORT=tcp://172.30.246.127:80
...
```

---

### Clean Up

You can destroy the created pod with:

```bash
$ kubectl delete pod/envs
```

---

### Exercise 

Service are exposed not only via DNS but also by environment variables. Details [here](https://kubernetes.io/docs/concepts/containers/container-environment-variables/) Try to create some service and access it from a different pod via environment variable.

--- 
 
## Namespaces

---

Kubernetes supports multiple virtual clusters backed by the same physical cluster. These virtual clusters are called namespaces.
 
+++

Each namespace has its own definitions, like quotas or access control or limits.  Namespaces are usually 
used to isolate pods.  For example, you can run a sandbox environment with one application in the **sandbox** namespace and run the same pod in another namespace named production. 

---

To list all namespaces (note that the output will depend on the environment
you're using):

+++

```bash
$ kubectl get ns
NAME              STATUS    AGE
default           Active    13d
kube-system       Active    13d
namingthings      Active    12d
openshift         Active    13d
openshift-infra   Active    13d
```

+++

You can learn more about a namespace using the `describe` verb, for example:

```bash
$ kubectl describe ns default
Name:   default
Labels: <none>
Status: Active

No resource quota.

No resource limits.
```

---
 
Now we will create a new [namespace](src/ns/ns.yaml)
called `test` now:

+++?code=src/ns/ns.yaml

+++

```bash
$ kubectl create -f src/ns/ns.yaml
namespace "test" created

$ kubectl get ns
NAME              STATUS    AGE
default           Active    13d
kube-system       Active    13d
namingthings      Active    12d
openshift         Active    13d
openshift-infra   Active    13d
test              Active    3s
```

+++

To launch a [pod](src/ns/pod.yaml) in
the newly created namespace `test`, do:

+++?code=src/ns/pod.yaml

+++

```bash
$ kubectl create --namespace=test -f src/ns/pod.yaml
```

+++

Note that using above method the namespace becomes a runtime property, that is,
you can easily deploy the same pod or service, or RC, etc. into multiple
namespaces (for example: `dev` and `prod`). 

+++

If you however prefer to hard-code the
namespace, you can define it directly in the `metadata` like so:

+++

```
apiVersion: v1
kind: Pod
metadata:
  name: podintest
  namespace: test
```

+++

To list namespaced objects such as our pod `podintest`, run following command as:

```bash
$ kubectl get pods --namespace=test
NAME        READY     STATUS    RESTARTS   AGE
podintest   1/1       Running   0          16s
```

---

### Clean Up

You can remove the namespace (and everything inside) with:

```bash
$ kubectl delete ns test
```

---


If you're an admin, you might want to check out the [docs](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/)
for more info how to handle namespaces.

---

### Exercise 

Namespaces are commonly used with [resource quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/). Try to create new namespace, assign some quota to it and then try to use more resources then quota allows. See previous link for more information how to work with quotas.

--- 
 
## Logs

---

Applications and system logs are the way to understand what is going on with the cluster
and the containers in a point in time.  It is a great tool that allows you to find out valuable
information from the application or the environment.  

+++

More advanced
[setups](http://some.ops4devs.info/logging/) consider logs across nodes and store
them in a central place, either within the cluster or via a dedicated (cloud-based) service.

---

Let's create a [pod](src/logging/pod.yaml)
called `logme` that runs a container writing to `stdout` and `stderr`:

+++?code=src/logging/pod.yaml

+++

```bash
$ kubectl create -f src/logging/pod.yaml
```

+++

To view the five most recent log lines of the `gen` container in the `logme` pod,
execute:

```bash
$ kubectl logs --tail=5 logme -c gen
Thu Apr 27 11:34:40 UTC 2017
Thu Apr 27 11:34:41 UTC 2017
Thu Apr 27 11:34:41 UTC 2017
Thu Apr 27 11:34:42 UTC 2017
Thu Apr 27 11:34:42 UTC 2017
```

---

To stream the log of the `gen` container in the `logme` pod (like `tail -f`), do:

```bash
$ kubectl logs -f --since=10s logme -c gen
Thu Apr 27 11:43:11 UTC 2017
Thu Apr 27 11:43:11 UTC 2017
Thu Apr 27 11:43:12 UTC 2017
Thu Apr 27 11:43:12 UTC 2017
Thu Apr 27 11:43:13 UTC 2017
...
```

+++

Note that if you wouldn't have specified `--since=10s` in the above command, you
would have gotten all log lines from the start of the container.

+++

You can also view logs of pods that have already completed their lifecycle.
For this we create a [pod](src/logging/oneshotpod.yaml)
called `oneshot` that counts down from 9 to 1 and then exits. Using the `-p` option
you can print the logs for previous instances of the container in a pod:

+++?code=src/logging/oneshotpod.yaml

+++

```bash
$ kubectl create -f src/logging/oneshotpod.yaml
$ kubectl logs -p oneshot -c gen
9
8
7
6
5
4
3
2
1
```

---

### Clean Up

You can remove the created pods with:

```bash
$ kubectl delete pod/logme pod/oneshot
```

---

### Exercise 

1. Deploy a pod that consists of 2 nginx containers.
1. Stream logs form the pod while sending requests to nginx. Observe how requests are distributed between containers. 

--- 
 
## Jobs

---

A job is an object that creates pods in order to execute a specific function and ensures that a specified number of pods successfully terminate.  As pods successfully complete, the job tracks the successful completions.  When the required number of completions is reached, the job is complete. 
If you delete a job, all the pods created by that job are deleted too.

---

Let's create a [job](src/jobs/job.yaml)
called `countdown` that supervises a pod counting from 9 down to 1:

+++?code=src/jobs/job.yaml

+++

```bash
$ kubectl create -f src/jobs/job.yaml
```

+++

We can see now the job and pod:

```bash
$ kubectl get jobs
NAME                      DESIRED   SUCCESSFUL   AGE
countdown                 1         1            5s

$ kubectl get pods --show-all
NAME                            READY     STATUS      RESTARTS   AGE
countdown-lc80g                 0/1       Completed   0          16s
```

+++

To learn more about the status of the job, do:

```bash
$ kubectl describe jobs/countdown
Name:           countdown
Namespace:      default
Image(s):       centos:7
Selector:       controller-uid=ff585b92-2b43-11e7-b44f-be3e8f4350ff
Parallelism:    1
Completions:    1
Start Time:     Thu, 27 Apr 2017 13:21:10 +0100
Labels:         controller-uid=ff585b92-2b43-11e7-b44f-be3e8f4350ff
                job-name=countdown
Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
No volumes.
Events:
  FirstSeen     LastSeen        Count   From                    SubobjectPath   Type            Reason                  Message
  ---------     --------        -----   ----                    -------------   --------        ------                  -------
  2m            2m              1       {job-controller }                       Normal          SuccessfulCreate        Created pod: countdown-lc80g
```

+++

And to see the output of the job via the pod it supervised, execute:

```bash
kubectl logs countdown-lc80g
9
8
7
6
5
4
3
2
1
```

---

### Clean Up

To clean up, use the `delete` verb on the job object which will remove all the
supervised pods:

```bash
$ kubectl delete job countdown
job "countdown" deleted
```

---

Note that there are also more advanced ways to use jobs, for example,
by utilizing a [work queue](https://kubernetes.io/docs/tasks/job/coarse-parallel-processing-work-queue/)
or scheduling the execution at a certain time via [cron jobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

---

### Exercise 

Use link provided above to deploy a job scheduled by cron.

--- 
 
## Nodes

---

In Kubernetes the nodes are the worker machines, the place where your pods run.

+++

As a developer you typically don't deal with nodes, however as an admin
you might want to know about your nodes [operations](https://kubernetes.io/docs/concepts/nodes/node/).

---

To list available nodes in your cluster (note that the output will depend on the environment
you're using):

```bash
$ kubectl get nodes
NAME             STATUS    AGE
192.168.99.100   Ready     14d
```

---

One interesting thing about nodes, is that Kubernetes can  schedule a pod to run on a certain node. 
To do this, first we need to put a label in the node:

```bash
$ kubectl label nodes 192.168.99.100 shouldrun=here
node "192.168.99.100" labeled
```

+++

Now we can create a [pod](src/nodes/pod.yaml)
That pod has a selector with a label that matches the label on the node, in this case `shouldrun=here`:

+++?code=src/nodes/pod.yaml

+++

```bash
$ kubectl create -f src/nodes/pod.yaml

$ kubectl get pods --output=wide
NAME                      READY     STATUS    RESTARTS   AGE       IP               NODE
onspecificnode            1/1       Running   0          8s        172.17.0.3       192.168.99.100
```

+++

To learn more about a specific node, `192.168.99.100` in our case, do:

```bash
$ kubectl describe node 192.168.99.100
Name:			192.168.99.100
Labels:			beta.kubernetes.io/arch=amd64
			beta.kubernetes.io/os=linux
			kubernetes.io/hostname=192.168.99.100
			shouldrun=here
Taints:			<none>
CreationTimestamp:	Wed, 12 Apr 2017 17:17:13 +0100
Phase:
Conditions:
  Type			Status	LastHeartbeatTime			LastTransitionTime			Reason				Message
  ----			------	-----------------			------------------			------				-------
  OutOfDisk 		False 	Thu, 27 Apr 2017 14:55:49 +0100 	Thu, 27 Apr 2017 09:18:13 +0100 KubeletHasSufficientDisk 	kubelet has sufficient disk space available
  MemoryPressure 	False 	Thu, 27 Apr 2017 14:55:49 +0100 	Wed, 12 Apr 2017 17:17:13 +0100 	KubeletHasSufficientMemory 	kubelet has sufficient memory available
  DiskPressure 		False 	Thu, 27 Apr 2017 14:55:49 +0100 	Wed, 12 Apr 2017 17:17:13 +0100 	KubeletHasNoDiskPressure 	kubelet has no disk pressure
  Ready 		True 	Thu, 27 Apr 2017 14:55:49 +0100 	Thu, 27 Apr 2017 09:18:24 +0100 	KubeletReady 			kubelet is posting ready status
Addresses:		192.168.99.100,192.168.99.100,192.168.99.100
Capacity:
 alpha.kubernetes.io/nvidia-gpu:	0
 cpu:					2
 memory:				2050168Ki
 pods:					20
Allocatable:
 alpha.kubernetes.io/nvidia-gpu:	0
 cpu:					2
 memory:				2050168Ki
 pods:					20
System Info:
 Machine ID:			896b6d970cd14d158be1fd1c31ff1a8a
 System UUID:			F7771C31-30B0-44EC-8364-B3517DBC8767
 Boot ID:			1d589b36-3413-4e82-af80-b2756342eed4
 Kernel Version:		4.4.27-boot2docker
 OS Image:			CentOS Linux 7 (Core)
 Operating System:		linux
 Architecture:			amd64
 Container Runtime Version:	docker://1.12.3
 Kubelet Version:		v1.5.2+43a9be4
 Kube-Proxy Version:		v1.5.2+43a9be4
ExternalID:			192.168.99.100
Non-terminated Pods:		(3 in total)
  Namespace			Name				CPU Requests	CPU Limits	Memory Requests	Memory Limits
  ---------			----				------------	----------	---------------	-------------
  default			docker-registry-1-hfpzp		100m (5%)	0 (0%)		256Mi (12%)	0 (0%)
  default			onspecificnode			0 (0%)		0 (0%)		0 (0%)		0 (0%)
  default			router-1-cdglk			100m (5%)	0 (0%)		256Mi (12%)	0 (0%)
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.
  CPU Requests	CPU Limits	Memory Requests	Memory Limits
  ------------	----------	---------------	-------------
  200m (10%)	0 (0%)		512Mi (25%)	0 (0%)
No events.
```

---

### Exercise 

1. Use mimicube ssh command to ssh into the host node.
1. Use docker command to list all containers. Make sure you understand relationships between pods and containers.
1. Examine docker container settings.
1. Explore iptables rules (specially those that belong to `nat` table) and try to understand how they work.
