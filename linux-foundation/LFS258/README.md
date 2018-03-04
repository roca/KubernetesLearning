LFS258 Kubernetes Fundamentals:

important links:

	Main class Launch page - https://training.linuxfoundation.org/portal
	LFS258 Class Forum     - https://www.linux.com/forums/lfs258-class-forum
        Lates class content    - https://training.linuxfoundation.org/cm/LFS258/

	Slack channel: https://kubernetes.slack.com
	Stack OverFlow: https://stackoverflow.com/search?q=kubernetes

	Main website: https://kubernetes.io/
	Github https://github.com/kubernetes/kubernetes


--------------------------------------------------------------------------
From LAB 3.1 step 11

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  