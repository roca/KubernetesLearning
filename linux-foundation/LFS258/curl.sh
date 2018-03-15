#!/bin/bash


#curl --cert ./client.pem --key ./client-key.pem --cacert ./ca.pem https://api.kubernetes.desertfoxdev.org/api/v1/pods
#curl --cert ./client.pem --key ./client-key.pem --cacert ./ca.pem https://api.kubernetes.desertfoxdev.org/api/v1/namespaces/default/pods -XPOST -H'Content-Type: application/json' -d@curlpod.json
curl https://api.kubernetes.desertfoxdev.org/api/v1/namespaces --header "Authorization: Bearer $token" -k
