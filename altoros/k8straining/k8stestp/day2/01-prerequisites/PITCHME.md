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

