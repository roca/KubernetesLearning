kops create cluster \
--name=kubernetes.desertfoxdev.org \
--state=${STATE_STORE} \
--zones=us-east-1a \
--node-count=2 \
--node-size=t2.small \
--master-size=t2.small \
--dns-zone=kubernetes.desertfoxdev.org \
--cloud=aws
# --authorization RBAC
# --yes
