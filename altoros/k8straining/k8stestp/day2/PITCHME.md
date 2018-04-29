## Prerequisites

---

### Split into pairs and fill this [spreadsheet](https://docs.google.com/spreadsheets/d/1raK04LwRjLZxEfKId6QG2W23GvaBbot5Qwpaks8DZQw/edit#gid=0)

You need to use your gmail accounts in this spreadsheed.

---

### Create a jumpbox

1. Open `https://console.cloud.google.com/`
1. Select a project. 
1. Open Compute engine -> VM instances
1. Press `Create Instance` button. Change name to jumpbox and set "Allow full access to all Cloud APIs". All other parameters can be left untouched.
1. When instance is ready use one of the available SSH options. (Each person in pair do this individually)

---

### Work in pairs efficiently 

Terminal Multiplexor (tmux) pair programming really efficient.
1. Install tmux sudo apt-get install tmux.
1. First person in pair runs `tmux` to start the session.
1. Second person runs `tmux a` to attach to the session.
1. Enjoy!
1. Use [tmux cheatsheet](https://gist.github.com/henrik/1967800) for advanced ussage.

---

### Google Cloud Platform

This tutorial leverages the [Google Cloud Platform](https://cloud.google.com/) to streamline provisioning of the compute infrastructure required to bootstrap a Kubernetes cluster from the ground up.

---

### Install the Google Cloud SDK

Follow the Google Cloud SDK [documentation](https://cloud.google.com/sdk/) to install and configure the `gcloud` command line utility. If you are using default image for GCP jumpbox gcloud command should be already available and configured for you. Use "gcloud compute instances list"  command to check this.

+++

Verify the Google Cloud SDK version is 173.0.0 or higher:

```
gcloud version
```

---

### Set a Default Compute Region and Zone

This tutorial assumes a default compute region and zone have been configured.

+++

If you are using the `gcloud` command-line tool for the first time `init` is the easiest way to do this:

```
gcloud init --console-only
```

+++

Otherwise set a default compute region:

```
gcloud config set compute/region us-west1
```

+++

Set a default compute zone:

```
gcloud config set compute/zone us-west1-c
```

+++

> Use the `gcloud compute zones list` command to view additional regions and zones.

---
## Installing the Client Tools

---

In this lab you will install the command line utilities required to complete this tutorial: [cfssl](https://github.com/cloudflare/cfssl), [cfssljson](https://github.com/cloudflare/cfssl), and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl).

---

### Install CFSSL

The `cfssl` and `cfssljson` command line utilities will be used to provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) and generate TLS certificates.

+++

Download and install `cfssl` and `cfssljson` from the [cfssl repository](https://pkg.cfssl.org):

+++

### For Linux 

```
curl -o cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -o cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
```

+++

```
chmod +x cfssl cfssljson

sudo mv cfssl cfssljson /usr/local/bin/
```

---

### Verification

Verify `cfssl` version 1.2.0 or higher is installed:

```
cfssl version
```

+++

output

```
Version: 1.2.0
Revision: dev
Runtime: go1.6
```

+++

The cfssljson command line utility does not provide a way to print its version.

---

### Install kubectl

The `kubectl` command line utility is used to interact with the Kubernetes API Server. Download and install `kubectl` from the official release binaries:

+++

### Linux 

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/
```

+++

### Verification

Verify `kubectl` version 1.8.0 or higher is installed:

```
kubectl version --client
```

+++

output

```
Client Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.0", GitCommit:"6e937839ac04a38cac63e6a7a306c5d035fe7b0a", GitTreeState:"clean", BuildDate:"2017-09-28T22:57:57Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"darwin/amd64"}
```

---
## Provisioning Compute Resources

---

Kubernetes requires a set of machines to host the Kubernetes control plane and the worker nodes where containers are ultimately run. In this lab you will provision the compute resources required for running a secure and highly available Kubernetes cluster across a single [compute zone](https://cloud.google.com/compute/docs/regions-zones/regions-zones).

---

### Networking

The Kubernetes [networking model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#kubernetes-model) assumes a flat network in which containers and nodes can communicate with each other. In cases where this is not desired [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) can limit how groups of containers are allowed to communicate with each other and external network endpoints.

---

### Virtual Private Cloud Network

In this section a dedicated [Virtual Private Cloud](https://cloud.google.com/compute/docs/networks-and-firewalls#networks) (VPC) network will be created to host the Kubernetes cluster.

+++

Create the `kubernetes-the-hard-way` custom VPC network:

```
gcloud compute networks create kubernetes-the-hard-way --mode custom
```

+++

A [subnet](https://cloud.google.com/compute/docs/vpc/#vpc_networks_and_subnets) must be provisioned with an IP address range large enough to assign a private IP address to each node in the Kubernetes cluster.

+++

Create the `kubernetes` subnet in the `kubernetes-the-hard-way` VPC network:

```
gcloud compute networks subnets create kubernetes \
  --network kubernetes-the-hard-way \
  --range 10.240.0.0/24
```

+++

The `10.240.0.0/24` IP address range can host up to 254 compute instances.

---

### Firewall Rules

+++

Create a firewall rule that allows internal communication across all protocols:

```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  --allow tcp,udp,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 10.240.0.0/24,10.200.0.0/16
```

+++

Create a firewall rule that allows external SSH, ICMP, and HTTPS:

```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 0.0.0.0/0
```

+++

An [external load balancer](https://cloud.google.com/compute/docs/load-balancing/network/) will be used to expose the Kubernetes API Servers to remote clients.

+++

List the firewall rules in the `kubernetes-the-hard-way` VPC network:

```
gcloud compute firewall-rules list --filter "network: kubernetes-the-hard-way"
```

+++

output

```
NAME                                         NETWORK                  DIRECTION  PRIORITY  ALLOW                 DENY
kubernetes-the-hard-way-allow-external       kubernetes-the-hard-way  INGRESS    1000      tcp:22,tcp:6443,icmp
kubernetes-the-hard-way-allow-internal       kubernetes-the-hard-way  INGRESS    1000      tcp,udp,icmp
```

---

### Kubernetes Public IP Address

+++

Allocate a static IP address that will be attached to the external load balancer fronting the Kubernetes API Servers:

```
gcloud compute addresses create kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region)
```

+++

Verify the `kubernetes-the-hard-way` static IP address was created in your default compute region:

```
gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"
```

+++

output

```
NAME                     REGION    ADDRESS        STATUS
kubernetes-the-hard-way  us-west1  XX.XXX.XXX.XX  RESERVED
```

---

### Compute Instances

The compute instances in this lab will be provisioned using [Ubuntu Server](https://www.ubuntu.com/server) 16.04, which has good support for the [cri-containerd container runtime](https://github.com/kubernetes-incubator/cri-containerd). Each compute instance will be provisioned with a fixed private IP address to simplify the Kubernetes bootstrapping process.

---

### Kubernetes Controllers

Create three compute instances which will host the Kubernetes control plane:

+++

```
for i in 0 1 2; do
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --private-network-ip 10.240.0.1${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,controller
done
```

---

### Kubernetes Workers

Each worker instance requires a pod subnet allocation from the Kubernetes cluster CIDR range. The pod subnet allocation will be used to configure container networking in a later exercise. The `pod-cidr` instance metadata will be used to expose pod subnet allocations to compute instances at runtime.

+++

The Kubernetes cluster CIDR range is defined by the Controller Manager's `--cluster-cidr` flag. In this tutorial the cluster CIDR range will be set to `10.200.0.0/16`, which supports 254 subnets.

+++

Create three compute instances which will host the Kubernetes worker nodes:

+++

```
for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1604-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
done
```

---

### Verification

List the compute instances in your default compute zone:

```
gcloud compute instances list
```

+++

output

```
NAME          ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
controller-0  us-west1-c  n1-standard-1               10.240.0.10  XX.XXX.XXX.XXX  RUNNING
controller-1  us-west1-c  n1-standard-1               10.240.0.11  XX.XXX.X.XX     RUNNING
controller-2  us-west1-c  n1-standard-1               10.240.0.12  XX.XXX.XXX.XX   RUNNING
worker-0      us-west1-c  n1-standard-1               10.240.0.20  XXX.XXX.XXX.XX  RUNNING
worker-1      us-west1-c  n1-standard-1               10.240.0.21  XX.XXX.XX.XXX   RUNNING
worker-2      us-west1-c  n1-standard-1               10.240.0.22  XXX.XXX.XX.XX   RUNNING
```

---
## Provisioning a CA and Generating TLS Certificates

---

In this lab you will provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) using CloudFlare's PKI toolkit, [cfssl](https://github.com/cloudflare/cfssl), then use it to bootstrap a Certificate Authority, and generate TLS certificates for the following components: etcd, kube-apiserver, kubelet, and kube-proxy.

---

### Certificate Authority

In this section you will provision a Certificate Authority that can be used to generate additional TLS certificates.

+++

Create the CA configuration file:

```
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF
```

+++

Create the CA certificate signing request:

```
cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF
```

+++

Generate the CA certificate and private key:

```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

+++

Results:

```
ca-key.pem
ca.pem
```

---

### Client and Server Certificates

In this section you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes `admin` user.

---

### The Admin Client Certificate

+++

Create the `admin` client certificate signing request:

```
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
```

+++

Generate the `admin` client certificate and private key:

```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
```

+++

Results:

```
admin-key.pem
admin.pem
```

---

### The Kubelet Client Certificates

+++

Kubernetes uses a [special-purpose authorization
mode](https://kubernetes.io/docs/admin/authorization/node/) called Node
Authorizer, that specifically authorizes API requests made by
[Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet). 

+++

In order to be authorized by the Node Authorizer, Kubelets must use a credential
that identifies them as being in the `system:nodes` group, with a username of `system:node:<nodeName>`. In this section you will create a certificate for each Kubernetes worker node that meets the Node Authorizer requirements.

+++

Generate a certificate and private key for each Kubernetes worker node:

```
for instance in worker-0 worker-1 worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done
```

+++

Results:

```
worker-0-key.pem
worker-0.pem
worker-1-key.pem
worker-1.pem
worker-2-key.pem
worker-2.pem
```

---

### The kube-proxy Client Certificate

+++

Create the `kube-proxy` client certificate signing request:

```
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
```

+++

Generate the `kube-proxy` client certificate and private key:

```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
```

+++

Results:

```
kube-proxy-key.pem
kube-proxy.pem
```

---

### The Kubernetes API Server Certificate

The `kubernetes-the-hard-way` static IP address will be included in the list of subject alternative names for the Kubernetes API Server certificate. This will ensure the certificate can be validated by remote clients.

+++

Retrieve the `kubernetes-the-hard-way` static IP address:

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

+++

Create the Kubernetes API Server certificate signing request:

```
cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
```

+++

Generate the Kubernetes API Server certificate and private key:

```
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
```

+++

Results:

```
kubernetes-key.pem
kubernetes.pem
```

---

### Distribute the Client and Server Certificates

+++

Copy the appropriate certificates and private keys to each worker instance:

```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done
```

+++

Copy the appropriate certificates and private keys to each controller instance:

```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem ${instance}:~/
done
```

+++

The `kube-proxy` and `kubelet` client certificates will be used to generate client authentication configuration files in the next lab.


---
## Generating Kubernetes Configuration Files for Authentication

---

In this lab you will generate [Kubernetes configuration files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), also known as kubeconfigs, which enable Kubernetes clients to locate and authenticate to the Kubernetes API Servers.

---

### Client Authentication Configs

In this section you will generate kubeconfig files for the `kubelet` and `kube-proxy` clients.

+++

The `scheduler` and `controller manager` access the Kubernetes API Server locally over an insecure API port which does not require authentication. The Kubernetes API Server's insecure port is only enabled for local access.

---

### Kubernetes Public IP Address

Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.

+++

Retrieve the `kubernetes-the-hard-way` static IP address:

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

---

### The kubelet Kubernetes Configuration File

When generating kubeconfig files for Kubelets the client certificate matching the Kubelet's node name must be used. This will ensure Kubelets are properly authorized by the Kubernetes [Node Authorizer](https://kubernetes.io/docs/admin/authorization/node/).

+++

Generate a kubeconfig file for each worker node:

```
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
```

+++

Results:

```
worker-0.kubeconfig
worker-1.kubeconfig
worker-2.kubeconfig
```

---

### The kube-proxy Kubernetes Configuration File

+++

Generate a kubeconfig file for the `kube-proxy` service:

```
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig
```

+++

```
kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
```

+++

```
kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
```

+++

```
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
```

---

### Distribute the Kubernetes Configuration Files

+++

Copy the appropriate `kubelet` and `kube-proxy` kubeconfig files to each worker instance:

```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
```

---
## Generating the Data Encryption Config and Key

---

Kubernetes stores a variety of data including cluster state, application configurations, and secrets. Kubernetes supports the ability to [encrypt](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) cluster data at rest.

+++

In this lab you will generate an encryption key and an [encryption config](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration) suitable for encrypting Kubernetes Secrets.

---

### The Encryption Key

+++

Generate an encryption key:

```
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

```

---

### The Encryption Config File

+++

Create the `encryption-config.yaml` encryption config file:

```
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
```

+++

Copy the `encryption-config.yaml` encryption config file to each controller instance:

```
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp encryption-config.yaml ${instance}:~/
done
```

---
## Bootstrapping the etcd Cluster

---

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/coreos/etcd). In this lab you will bootstrap a three node etcd cluster and configure it for high availability and secure remote access.

---

### Prerequisites

+++

The commands in this lab must be run on each controller instance: `controller-0`, `controller-1`, and `controller-2`. Login to each controller instance using the `gcloud` command. Example:

```
gcloud compute ssh controller-0
```

---

### Bootstrapping an etcd Cluster Member

---

### Download and Install the etcd Binaries

+++

Download the official etcd release binaries from the [coreos/etcd](https://github.com/coreos/etcd) GitHub project:

```
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.2.8/etcd-v3.2.8-linux-amd64.tar.gz"
```

+++

Extract and install the `etcd` server and the `etcdctl` command line utility:

```
tar -xvf etcd-v3.2.8-linux-amd64.tar.gz
```

+++

```
sudo mv etcd-v3.2.8-linux-amd64/etcd* /usr/local/bin/
```

---

### Configure the etcd Server

```
sudo mkdir -p /etc/etcd /var/lib/etcd
```

+++

```
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
```

+++

The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP address for the current compute instance:

```
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
```

+++

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

```
ETCD_NAME=$(hostname -s)
```

+++

Create the `etcd.service` systemd unit file:

```
cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://10.240.0.10:2380,controller-1=https://10.240.0.11:2380,controller-2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

### Start the etcd Server

```
sudo mv etcd.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable etcd

sudo systemctl start etcd
```

+++

Remember to run the above commands on each controller node: `controller-0`, `controller-1`, and `controller-2`.

---

### Verification

+++

List the etcd cluster members:

```
ETCDCTL_API=3 etcdctl member list
```

+++

output

```
3a57933972cb5131, started, controller-2, https://10.240.0.12:2380, https://10.240.0.12:2379
f98dc20bce6225a0, started, controller-0, https://10.240.0.10:2380, https://10.240.0.10:2379
ffed16798470cab5, started, controller-1, https://10.240.0.11:2380, https://10.240.0.11:2379
```

---
## Bootstrapping the Kubernetes Control Plane

---

In this lab you will bootstrap the Kubernetes control plane across three compute instances and configure it for high availability. 

+++

You will also create an external load balancer that exposes the Kubernetes API Servers to remote clients. The following components will be installed on each node: Kubernetes API Server, Scheduler, and Controller Manager.

---

### Prerequisites

The commands in this lab must be run on each controller instance:
`controller-0`, `controller-1`, and `controller-2`. Login to each controller
instance using the `gcloud` command.

+++

Example

```
gcloud compute ssh controller-0
```

---

### Provision the Kubernetes Control Plane

---

### Download and Install the Kubernetes Controller Binaries

+++

Download the official Kubernetes release binaries:

```
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl"
```

+++

Install the Kubernetes binaries:

```
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl

sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
```

---

### Configure the Kubernetes API Server

```
sudo mkdir -p /var/lib/kubernetes/
```

+++

```
sudo mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem encryption-config.yaml /var/lib/kubernetes/
```

+++

The instance internal IP address will be used advertise the API Server to members of the cluster. Retrieve the internal IP address for the current compute instance:

```
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
```

+++

Create the `kube-apiserver.service` systemd unit file:

```
cat > kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --admission-control=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-swagger-ui=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://10.240.0.10:2379,https://10.240.0.11:2379,https://10.240.0.12:2379 \\
  --event-ttl=1h \\
  --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --insecure-bind-address=127.0.0.1 \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/ca-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-ca-file=/var/lib/kubernetes/ca.pem \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

### Configure the Kubernetes Controller Manager

+++

Create the `kube-controller-manager.service` systemd unit file:

```
cat > kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --leader-elect=true \\
  --master=http://127.0.0.1:8080 \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/ca-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

### Configure the Kubernetes Scheduler

+++

Create the `kube-scheduler.service` systemd unit file:

```
cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --leader-elect=true \\
  --master=http://127.0.0.1:8080 \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

### Start the Controller Services

```
sudo mv kube-apiserver.service kube-scheduler.service kube-controller-manager.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler

sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler
```

+++

Allow up to 10 seconds for the Kubernetes API Server to fully initialize.

---

### Verification

```
kubectl get componentstatuses
```

+++

```
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
```

+++

Remember to run the above commands on each controller node: `controller-0`, `controller-1`, and `controller-2`.

---

### RBAC for Kubelet Authorization

In this section you will configure RBAC permissions to allow the Kubernetes API Server to access the Kubelet API on each worker node. Access to the Kubelet API is required for retrieving metrics, logs, and executing commands in pods.

+++

> This tutorial sets the Kubelet `--authorization-mode` flag to `Webhook`. Webhook mode uses the [SubjectAccessReview](https://kubernetes.io/docs/admin/authorization/#checking-api-access) API to determine authorization.

+++

```
gcloud compute ssh controller-0
```

+++

Create the `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/admin/authorization/rbac/#role-and-clusterrole) with permissions to access the Kubelet API and perform most common tasks associated with managing pods:

+++

```
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
```

+++

The Kubernetes API Server authenticates to the Kubelet as the `kubernetes` user using the client certificate as defined by the `--kubelet-client-certificate` flag.

+++

Bind the `system:kube-apiserver-to-kubelet` ClusterRole to the `kubernetes` user:

```
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
```

---

### The Kubernetes Frontend Load Balancer

In this section you will provision an external load balancer to front the Kubernetes API Servers. The `kubernetes-the-hard-way` static IP address will be attached to the resulting load balancer.

+++

The compute instances created in this tutorial will not have permission to complete this section. Run the following commands from the same machine used to create the compute instances.

+++

Create the external load balancer network resources:

```
gcloud compute target-pools create kubernetes-target-pool
```

+++

```
gcloud compute target-pools add-instances kubernetes-target-pool \
  --instances controller-0,controller-1,controller-2
```

+++

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(name)')
```

+++

```
gcloud compute forwarding-rules create kubernetes-forwarding-rule \
  --address ${KUBERNETES_PUBLIC_ADDRESS} \
  --ports 6443 \
  --region $(gcloud config get-value compute/region) \
  --target-pool kubernetes-target-pool
```

---

### Verification

+++

Retrieve the `kubernetes-the-hard-way` static IP address:

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

---

Make a HTTP request for the Kubernetes version info:

```
curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
```

+++

> output

```
{
  "major": "1",
  "minor": "8",
  "gitVersion": "v1.8.0",
  "gitCommit": "6e937839ac04a38cac63e6a7a306c5d035fe7b0a",
  "gitTreeState": "clean",
  "buildDate": "2017-09-28T22:46:41Z",
  "goVersion": "go1.8.3",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

---
## Bootstrapping the Kubernetes Worker Nodes

---

In this lab you will bootstrap three Kubernetes worker nodes. The following components will be installed on each node: [runc](https://github.com/opencontainers/runc), [container networking plugins](https://github.com/containernetworking/cni), [cri-containerd](https://github.com/kubernetes-incubator/cri-containerd), [kubelet](https://kubernetes.io/docs/admin/kubelet), and [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

---

### Prerequisites

+++

The commands in this lab must be run on each worker instance: `worker-0`, `worker-1`, and `worker-2`. Login to each worker instance using the `gcloud` command. Example:

```
gcloud compute ssh worker-0
```

---

### Provisioning a Kubernetes Worker Node

+++

Install the OS dependencies:

```
sudo apt-get -y install socat
```

+++

The socat binary enables support for the `kubectl port-forward` command.

---

### Download and Install Worker Binaries

+++

```
wget -q --show-progress --https-only --timestamping \
  https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz \
  https://github.com/kubernetes-incubator/cri-containerd/releases/download/v1.0.0-alpha.0/cri-containerd-1.0.0-alpha.0.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubelet
```

+++

Create the installation directories:

```
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

+++

Install the worker binaries:

```
sudo tar -xvf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/

sudo tar -xvf cri-containerd-1.0.0-alpha.0.tar.gz -C /

chmod +x kubectl kube-proxy kubelet

sudo mv kubectl kube-proxy kubelet /usr/local/bin/
```

---

### Configure CNI Networking

+++

Retrieve the Pod CIDR range for the current compute instance:

```
POD_CIDR=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/pod-cidr)
```

+++

Create the `bridge` network configuration file:

```
cat > 10-bridge.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
```

+++

Create the `loopback` network configuration file:

```
cat > 99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "type": "loopback"
}
EOF
```

+++

Move the network configuration files to the CNI configuration directory:

```
sudo mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
```

---

### Configure the Kubelet

```
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
```

+++

```
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
```

+++

```
sudo mv ca.pem /var/lib/kubernetes/
```

+++

Create the `kubelet.service` systemd unit file:

```
cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=cri-containerd.service
Requires=cri-containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --allow-privileged=true \\
  --anonymous-auth=false \\
  --authorization-mode=Webhook \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --cluster-dns=10.32.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/cri-containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --pod-cidr=${POD_CIDR} \\
  --register-node=true \\
  --require-kubeconfig \\
  --runtime-request-timeout=15m \\
  --tls-cert-file=/var/lib/kubelet/${HOSTNAME}.pem \\
  --tls-private-key-file=/var/lib/kubelet/${HOSTNAME}-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

### Configure the Kubernetes Proxy

+++

```
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
```

+++

Create the `kube-proxy.service` systemd unit file:

```
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --cluster-cidr=10.200.0.0/16 \\
  --kubeconfig=/var/lib/kube-proxy/kubeconfig \\
  --proxy-mode=iptables \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

---

### Start the Worker Services

+++

```
sudo mv kubelet.service kube-proxy.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable containerd cri-containerd kubelet kube-proxy

sudo systemctl start containerd cri-containerd kubelet kube-proxy
```

+++

Remember to run the above commands on each worker node: `worker-0`, `worker-1`, and `worker-2`.

---

### Verification

+++

Login to one of the controller nodes:

```
gcloud compute ssh controller-0
```

+++

List the registered Kubernetes nodes:

```
kubectl get nodes
```

+++

output

```
NAME       STATUS    ROLES     AGE       VERSION
worker-0   Ready     <none>    1m        v1.8.0
worker-1   Ready     <none>    1m        v1.8.0
worker-2   Ready     <none>    1m        v1.8.0
```

---
## Configuring kubectl for Remote Access

---

In this lab you will generate a kubeconfig file for the `kubectl` command line utility based on the `admin` user credentials.

+++

Run the commands in this lab from the same directory used to generate the admin client certificates.

---

### The Admin Kubernetes Configuration File

Each kubeconfig requires a Kubernetes API Server to connect to. To support high availability the IP address assigned to the external load balancer fronting the Kubernetes API Servers will be used.

+++

Retrieve the `kubernetes-the-hard-way` static IP address:

```
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
```

+++

Generate a kubeconfig file suitable for authenticating as the `admin` user:

```
kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443
```

+++

```
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem
```

+++

```
kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
```

+++

```
kubectl config use-context kubernetes-the-hard-way
```

---

### Verification

+++

Check the health of the remote Kubernetes cluster:

```
kubectl get componentstatuses
```

+++

output

```
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-2               Healthy   {"health": "true"}
etcd-0               Healthy   {"health": "true"}
etcd-1               Healthy   {"health": "true"}
```

+++

List the nodes in the remote Kubernetes cluster:

```
kubectl get nodes
```

+++

output

```
NAME       STATUS    ROLES     AGE       VERSION
worker-0   Ready     <none>    2m        v1.8.0
worker-1   Ready     <none>    2m        v1.8.0
worker-2   Ready     <none>    2m        v1.8.0
```

---
## Provisioning Pod Network Routes

---

Pods scheduled to a node receive an IP address from the node's Pod CIDR range. At this point pods can not communicate with other pods running on different nodes due to missing network [routes](https://cloud.google.com/compute/docs/vpc/routes).

+++

In this lab you will create a route for each worker node that maps the node's Pod CIDR range to the node's internal IP address.

+++

There are [other ways](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this) to implement the Kubernetes networking model.

---

### The Routing Table

In this section you will gather the information required to create routes in the `kubernetes-the-hard-way` VPC network.

+++

Print the internal IP address and Pod CIDR range for each worker instance:

```
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done
```

+++

output

```
10.240.0.20 10.200.0.0/24
10.240.0.21 10.200.1.0/24
10.240.0.22 10.200.2.0/24
```

---

### Routes

+++

Create network routes for each worker instance:

```
for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
```

+++

List the routes in the `kubernetes-the-hard-way` VPC network:

```
gcloud compute routes list --filter "network: kubernetes-the-hard-way"
```

+++

output

```
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-77bcc6bee33b5535  kubernetes-the-hard-way  10.240.0.0/24                            1000
default-route-b11fc914b626974d  kubernetes-the-hard-way  0.0.0.0/0      default-internet-gateway  1000
kubernetes-route-10-200-0-0-24  kubernetes-the-hard-way  10.200.0.0/24  10.240.0.20               1000
kubernetes-route-10-200-1-0-24  kubernetes-the-hard-way  10.200.1.0/24  10.240.0.21               1000
kubernetes-route-10-200-2-0-24  kubernetes-the-hard-way  10.200.2.0/24  10.240.0.22               1000
```

---
## Deploying the DNS Cluster Add-on

---

In this lab you will deploy the [DNS add-on](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) which provides DNS based service discovery to applications running inside the Kubernetes cluster.

---

### The DNS Cluster Add-on

+++

Deploy the `kube-dns` cluster add-on:

```
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/kube-dns.yaml
```

+++

> output

```
serviceaccount "kube-dns" created
configmap "kube-dns" created
service "kube-dns" created
deployment "kube-dns" created
```

+++

List the pods created by the `kube-dns` deployment:

```
kubectl get pods -l k8s-app=kube-dns -n kube-system
```

+++

output

```
NAME                        READY     STATUS    RESTARTS   AGE
kube-dns-3097350089-gq015   3/3       Running   0          20s
kube-dns-3097350089-q64qc   3/3       Running   0          20s
```

---

### Verification

+++

Create a `busybox` deployment:

```
kubectl run busybox --image=busybox --command -- sleep 3600
```

+++

List the pod created by the `busybox` deployment:

```
kubectl get pods -l run=busybox
```

+++

output

```
NAME                       READY     STATUS    RESTARTS   AGE
busybox-2125412808-mt2vb   1/1       Running   0          15s
```

+++

Retrieve the full name of the `busybox` pod:

```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
```

+++

Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod:

```
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

+++

output

```
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

---
## Smoke Test

---

In this lab you will complete a series of tasks to ensure your Kubernetes cluster is functioning correctly.

---

### Data Encryption

In this section you will verify the ability to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#verifying-that-data-is-encrypted).

+++

Create a generic secret:

```
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

+++

Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

```
gcloud compute ssh controller-0 \
  --command "ETCDCTL_API=3 etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
```

+++

output

```
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 70 88 d8 52 83 b7 96  |:v1:key1:p..R...|
00000050  04 a3 bd 7e 42 9e 8a 77  2f 97 24 a7 68 3f c5 ec  |...~B..w/.$.h?..|
00000060  9e f7 66 e8 a3 81 fc c8  3c df 63 71 33 0a 87 8f  |..f.....<.cq3...|
00000070  0e c7 0a 0a f2 04 46 85  33 92 9a 4b 61 b2 10 c0  |......F.3..Ka...|
00000080  0b 00 05 dd c3 c2 d0 6b  ff ff f2 32 3b e0 ec a0  |.......k...2;...|
00000090  63 d3 8b 1c 29 84 88 71  a7 88 e2 26 4b 65 95 14  |c...)..q...&Ke..|
000000a0  dc 8d 59 63 11 e5 f3 4e  b4 94 cc 3d 75 52 c7 07  |..Yc...N...=uR..|
000000b0  73 f5 b4 b0 63 aa f9 9d  29 f8 d6 88 aa 33 c4 24  |s...c...)....3.$|
000000c0  ac c6 71 2b 45 98 9e 5f  c6 a4 9d a2 26 3c 24 41  |..q+E.._....&<$A|
000000d0  95 5b d3 2c 4b 1e 4a 47  c8 47 c8 f3 ac d6 e8 cb  |.[.,K.JG.G......|
000000e0  5f a9 09 93 91 d7 5d c9  c2 68 f8 cf 3c 7e 3b a3  |_.....]..h..<~;.|
000000f0  db d8 d5 9e 0c bf 2a 2f  58 0a                    |......*/X.|
000000fa
```

+++

The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

---

### Deployments

In this section you will verify the ability to create and manage [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

+++

Create a deployment for the [nginx](https://nginx.org/en/) web server:

```
kubectl run nginx --image=nginx
```

+++

List the pod created by the `nginx` deployment:

```
kubectl get pods -l run=nginx
```

+++

output

```
NAME                     READY     STATUS    RESTARTS   AGE
nginx-4217019353-b5gzn   1/1       Running   0          15s
```

---

### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

+++

Retrieve the full name of the `nginx` pod:

```
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
```

+++

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```
kubectl port-forward $POD_NAME 8080:80
```

+++

output

```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

+++

In a new terminal make an HTTP request using the forwarding address:

```
curl --head http://127.0.0.1:8080
```

+++

output

```
HTTP/1.1 200 OK
Server: nginx/1.13.5
Date: Mon, 02 Oct 2017 01:04:20 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 08 Aug 2017 15:25:00 GMT
Connection: keep-alive
ETag: "5989d7cc-264"
Accept-Ranges: bytes
```

+++

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^C
```

---

### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

+++

Print the `nginx` pod logs:

```
kubectl logs $POD_NAME
```

+++

output

```
127.0.0.1 - - [02/Oct/2017:01:04:20 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.54.0" "-"
```

---

### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

+++

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```
kubectl exec -ti $POD_NAME -- nginx -v
```

+++

output

```
nginx version: nginx/1.13.5
```

---

### Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

+++

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service:

```
kubectl expose deployment nginx --port 80 --type NodePort
```

+++

The LoadBalancer service type can not be used because your cluster is not configured with [cloud provider integration](https://kubernetes.io/docs/getting-started-guides/scratch/#cloud-provider). Setting up cloud provider integration is out of scope for this tutorial.

+++

Retrieve the node port assigned to the `nginx` service:

```
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

+++

Create a firewall rule that allows remote access to the `nginx` node port:

```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way
```

+++

Retrieve the external IP address of a worker instance:

```
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
```

+++

Make an HTTP request using the external IP address and the `nginx` node port:

```
curl -I http://${EXTERNAL_IP}:${NODE_PORT}
```

+++

output

```
HTTP/1.1 200 OK
Server: nginx/1.13.5
Date: Mon, 02 Oct 2017 01:06:11 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 08 Aug 2017 15:25:00 GMT
Connection: keep-alive
ETag: "5989d7cc-264"
Accept-Ranges: bytes
```

---
## Exercise

1. Deploy worker-4. 
1. Stop one of the controller instances. Make sure that API is still available.
1. Deploy some pod using deploydment or replication controller. Find out on what worker node this pod is deployed. Stop this node. Observe whether pod is migrated on different node.
1. Do the same execrise as previous, but for pod with volume mounted to it. See what happend to volume data after node is deleted.

---

1. After previoud 2 exercises you should have 2 worker nodes running. Deploy 4 pods. Restore 2 previously deleted kubernetes nodes and make them join the cluster. Observer whether pods are redistributed across the cluster. Now redeploy 2 out of 4 previously deployed pods and find out what nodes they ocupied.
1. (Advanced) Add different subnet.  Migrate one worker to this subnet and make sure that pods deployed to this worker can communicate with all other pods.
---
## Cleaning Up

---

In this labs you will delete the compute resources created during this tutorial.

---

### Compute Instances

Delete the controller and worker compute instances:

```
gcloud -q compute instances delete \
  controller-0 controller-1 controller-2 \
  worker-0 worker-1 worker-2
```

---

### Networking

Delete the external load balancer network resources:

```
gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
  --region $(gcloud config get-value compute/region)
```

+++

```
gcloud -q compute target-pools delete kubernetes-target-pool
```

+++

Delete the `kubernetes-the-hard-way` static IP address:

```
gcloud -q compute addresses delete kubernetes-the-hard-way
```

+++

Delete the `kubernetes-the-hard-way` firewall rules:

```
gcloud -q compute firewall-rules delete \
  kubernetes-the-hard-way-allow-nginx-service \
  kubernetes-the-hard-way-allow-internal \
  kubernetes-the-hard-way-allow-external
```

+++

Delete the Pod network routes:

```
gcloud -q compute routes delete \
  kubernetes-route-10-200-0-0-24 \
  kubernetes-route-10-200-1-0-24 \
  kubernetes-route-10-200-2-0-24
```

+++

Delete the `kubernetes` subnet:

```
gcloud -q compute networks subnets delete kubernetes
```

+++

Delete the `kubernetes-the-hard-way` network VPC:

```
gcloud -q compute networks delete kubernetes-the-hard-way
```

