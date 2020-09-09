
Exam Registration Details
    Confirmation Code: CF3-8E3
    Candidate Id: 0586794786
    Transaction Date 9/30/2018

 'man lf_exam'.

 kubectl create secret generic another-secret --from-literal=key1=value2

 REDO: 6,8,12


Notes

ConfigMAps
Volumes

kubectl get pods -v=9
kubectl get pods -o json | jq -r .items
kubectl api-versions
kubectl proxy
REST (Representational State Transfer)

kubectl explain pod

    describe
    explain
    exec
    label
    annotate
    get pods --export


    kubectl run foo --restart=Never --image=redis --dry-run=true -o json > foo.json

    kubectl run foo123 --replicas=2 --image=nginx --dry-run=true -o yaml

    kubectl expose deployment foo123 --port=80 --type=NodePort

    http://127.0.0.1:8001/api/v1/namespaces/default/services/foo123/proxy/


    curl -XPOST -H 'Content-type: application/json' -d @foo.json http://127.0.0.1:8001/api/v1/namespaces/default/pods

    curl -XDELETE http://127.0.0.1:8001/api/v1/namespaces/default/pods/foo

    curl -XGET http://127.0.0.1:8001/api/v1/namespaces/default/pods


    kubectl set image deployment velo velocon=runseb/2048


    kubetcl get pod -o json| jq -r .items[].status.podIp


    kubectl rollout history 


api/namespaces/default/sevices/game/proxy/


kubectl run busybox --image=busybox:1.28 --command sleep 3600

kubectl exec -it busybox-2042752919-8x8r4  -- nslookup foo123



