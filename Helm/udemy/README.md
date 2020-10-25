# Udemy Helm Course
    -  https://www.udemy.com/course/helm-package-manager-for-kubernetes-complete-master-course/

# Helm Docs
    - https://helm.sh/

# Helm Hub
    - https://artifacthub.io/

# Kubernetes Dashboard
    - first do a 'kubectl proxy' on local machine
    - http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

## Sum usefull helm commands

    - helm get manifest releasename-test
    - helm ls 
    - helm uninstall releasename-test
    - helm install releasename-test ./mychart
    - helm install --debug --dry-run releasename-test ./mychart
    - helm install --debug --dry-run --set costCode=CC0000 releasename-test ./mychart

    - cd <HELM_PROJECT>/charts && helm create mysubchart
    - helm install --debug --dry-run releasename-test ./mychart/charts/mysubchart
