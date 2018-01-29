kops create cluster \
--name=kubernetes.desertfoxdev.org \
--state=${STATE_STORE} \
--zones=us-east-1a \
--node-count=3 \
--node-size=t2.micro \
--master-size=t2.micro \
--dns-zone=kubernetes.desertfoxdev.org \
--cloud=aws 
# --yes
