# kube authentication resources

Add oidc setup to kops cluster:

```
spec:
  kubeAPIServer:
    oidcIssuerURL: https://desertfoxdev.auth0.com/
    oidcClientID: OVD83RVDb0JNRWiVjXzFBHghKfaCM3DX
    oidcUsernameClaim: sub
```

Create UI:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.6.3.yaml
```

