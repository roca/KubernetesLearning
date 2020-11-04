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

## Repository options
    - https://chartmuseum.com/
    - helm repo add mychartmuseumrepo http://localhost:8080/
    - helm search repo mychartmuseumrepo
    - helm package repotest/
    - curl --data-binary "@repotest-0.1.0.tgz" http://localhost:8080/api/charts
    - helm repo update
    - helm search repo -l mychartmuseumrepo

## Helm Push Pligin: 
    - https://github.com/chartmuseum/helm-push
    - helm plugin install https://github.com/chartmuseum/helm-push.git

## Create a repo index.yaml
    - helm repo index .

## Helm upgrade
    - helm push upgrade-rlbk/ mychartmuseumrepo
    - helm repo update
    - helm search repo -l mychartmuseumrepo
    - helm install install-upgrade-rlbk-demo mychartmuseumrepo/upgrade-rlbk
    - helm upgrade install-upgrade-rlbk-demo mychartmuseumrepo/upgrade-rlbk
    - helm history install-upgrade-rlbk-demo
    - helm rollback install-upgrade-rlbk-demo 2
    - kubectl patch svc mydeptestinstall-dependencytest -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.1.102"]}}'

## Dependecies:
    - helm dependency build dependencytest/
    - helm dependency update dependencytest/
    - helm install