# Spinnaker build
* Make changes to spinnaker.yml
* helm install --name demo -f spinnaker.yml stable/spinnaker

# Git and docker
* Setup git repository on github or bitbucket
* Setup docker hub account
* Link docker hub account with github or bitbucket
* Create new automated build

# Spinnaker configuration
* Create new application
* Create new loadbalancer
* Create new server group
* Create new pipeline

# Persistence
* Currently minio (an S3 compatible storage system) is providing persistence for Spinnaker
  * If you are on AWS, you might rather want to use S3 itself, but that doesn't seem to be possible yet with this chart

1. You will need to create 2 port forwarding tunnels in order to access the Spinnaker UI:
  export DECK_POD=$(kubectl get pods --namespace default -l "component=deck,app=demo-spinnaker" -o jsonpath="{.items[0].metadata.name}")
  export DECK_POD=$(kubectl get pods --namespace spinnaker  spin-deck-v000-4lprg -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward --namespace default $DECK_POD 9000

2. Visit the Spinnaker UI by opening your browser to: http://127.0.0.1:9000

For more info on the Kubernetes integration for Spinnaker, visit:
  http://www.spinnaker.io/docs/kubernetes-source-to-prod
