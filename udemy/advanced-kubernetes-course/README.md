# Kubernetes course
This repository contains the course files for my Kubernetes course on Udemy: https://www.udemy.com/learn-devops-the-complete-kubernetes-course/?couponCode=KUBERNETES_GIT


Notes for course work  https://app.pluralsight.com/library/courses/getting-started-kubernetes/table-of-contents

- kops_script creates aws cluster

- For dash board stuff

  To install dashboard ui on to the master: 
  
      kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.6.0.yaml
    
  Use this to get the username/password to login: 
  
      kubectl config view --minify
  
  The dashboard can be reached at 
  
      https://{URL_OF_LOADBALANCED_API_ENDPOINT/ui
  
  
  For general intructions on working with kop look here: https://github.com/kubernetes/kops/tree/master/docs

  ns-814.awsdns-37.net.
ns-1815.awsdns-34.co.uk.
ns-221.awsdns-27.com.
ns-1365.awsdns-42.org.
