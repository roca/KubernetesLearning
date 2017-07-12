home for course work

- kops_script creates aws cluster

- For dash board stuff

  To install dashboard ui on to the master: 
  
    kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.6.0.yaml
    
  Use this to get the username/password to login: 
  
    kubectl config view --minify
  
  The dashboard can be reached at https://{URL_OF_LOADBALANCED_API_ENDPOINT/ui
