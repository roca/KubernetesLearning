# kube authorization with auth0

Add oidc setup to kops cluster:

```
spec:
  kubeAPIServer:
    oidcIssuerURL: https://desertfoxdev.auth0.com/
    oidcClientID: OVD83RVDb0JNRWiVjXzFBHghKfaCM3DX
    oidcUsernameClaim: name
    oidcGroupsClaim: http://authserver.kubernetes.desertfoxdev.org/claims/groups
  authorization:
    rbac: {}

```

Auth0 rule for groups

```
function (user, context, callback) {
  var namespace = 'http://authserver.kubernetes.desertfoxdev.org/claims/'; // You can set your own namespace, but do not use an Auth0 domain

  // Add the namespaced tokens. Remove any which is not necessary for your scenario
  context.idToken[namespace + "permissions"] = user.permissions;
  context.idToken[namespace + "groups"] = user.groups;
  context.idToken[namespace + "roles"] = user.roles;
  
  callback(null, user, context);
}
```

Spinnake RBAC setup
https://blog.spinnaker.io/spinnaker-kubernetes-rbac-c40f1f73c172

kubectl get secret spinnaker-service-account-token-b3q33 -o json  | jq -r .data.token  | base64
