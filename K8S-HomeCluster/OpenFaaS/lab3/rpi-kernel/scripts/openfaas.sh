curl -sLSf https://cli.openfaas.com | sudo sh


cat <<EOF >> /home/vagrant/.profile
export OPENFAAS_PREFIX="rcampbell"
export OPENFAAS_URL=http://192.168.1.149:31112
export PATH=${PATH}:/usr/local/bin
export PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
echo -n $PASSWORD | faas-cli login --username=admin --password-stdin
EOF
