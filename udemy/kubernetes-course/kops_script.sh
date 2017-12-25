kops create cluster \
--dns-zone=kubernetes.desertfoxdev.org \
--state=${STATE_STORE} \
--cloud=aws \
--zones=us-east-1a \
--node-count=2 \
--node-size=t2.micro \
--master-size=t2.micro \
--name=kubernetes.desertfoxdev.org
# --yes
