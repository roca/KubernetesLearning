## Exercises

1. Deploy worker-4. 
1. Stop one of the controller instances. Make sure that API is still available.
1. Deploy some pod using deploydment or replication controller. Find out on what worker node this pod is deployed. Stop this node. Observe whether pod is migrated on different node.
1. Do the same execrise as previous, but for pod with volume mounted to it. See what happend to volume data after node is deleted.

---

1. After previoud 2 exercises you should have 2 worker nodes running. Deploy 4 pods. Restore 2 previously deleted kubernetes nodes and make them join the cluster. Observer whether pods are redistributed across the cluster. Now redeploy 2 out of 4 previously deployed pods and find out what nodes they ocupied.
1. (Advanced) Add different subnet.  Migrate one worker to this subnet and make sure that pods deployed to this worker can communicate with all other pods.
