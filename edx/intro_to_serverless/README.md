# Return the top 5 results
    - faas-cli store list | head -n 5

# Filter the results for the word analysis
    - faas-cli store list | grep Analysis
    - faas-cli store deploy SentimentAnalysis

# You creat localy but
# you must buld/deploy/push the functions in the rpi environement
    1. FROM LOCAL: scp -r OpenFaas/* pirate@master:~/OpenFaas/
    2. ON THE MASTER: cd ~/OpenFaas/
    3. faas-cli up -f <FUNCTION>

## Docker
### Inspect image for os/architecture
    - docker image inspect --format '{{.Os}}/{{.Architecture}}' rcampbell/dotproduct
    - docker manifest inspect rcampbell/dotproduct

    - docker buildx use rpi3-ssh
    - docker buildx build -t rcampbell/dotproduct:latest --platform linux/arm/v7  .
    - docker push rcampbell/dotproduct:latest

## Prometheus
    - kubectl port-forward deployment/prometheus 9090:9090 -n openfaas &

## Deploy a pod for Grafana:

    - helm install grafana grafana/grafana
    - kubectl port-forward deployment/grafana 3000:3000 -n openfaas




### Note;
    - kubectl -n openfaas port-forward gateway-6b44db58dc-kqjpw 8080:8080