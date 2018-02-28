kops create cluster \
--name=kubernetes-2.desertfoxdev.org \
--state=${STATE_STORE} \
--zones=us-west-1c \
--node-count=2 \
--node-size=t2.small \
--master-size=t2.small \
--dns-zone=kubernetes-2.desertfoxdev.org \
--cloud=aws
# --authorization RBAC
# --yes
