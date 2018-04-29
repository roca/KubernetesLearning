---

## User management

There are two types of user accounts in Kubernetes:

1. Service accounts
1. Normal users

+++

Service are managed by Kubernetes and allow processes access cluster API

+++

Normal user accounts are assumed to be managed by an outside independent service

---

### Authentication Strategies

---

### X509 Client Certs

Client provides a certificate that is signed by certification authority (CA)
trusted by API server. `CN` attribute specifies the user name and `O` attribute
specifies the user group.

+++

Example CSR for user `jbeda` belonging to groups `app1` and `app2`

```
openssl req -new -key jbeda.pem -out jbeda-csr.pem -subj "/CN=jbeda/O=app1/O=app2"
```

---

### Static Token File

Server reads client tokens from the plain text file on the local volume or NFS
share.

```
token,user,uid,"group1,group2,group3"
```

+++

Client puts token to the headers of each requests

```
Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269
```

---

### Static Password File

Username and passwords for the Basic HTTP authentication are stored in the plain
text file

```
password,user,uid,"group1,group2,group3"
```

---

### External Integration

Kubernetes client `kubectl` may be integrated with external identity provider
that supports [OpenID Connect](https://openid.net/connect/) flavor of OAuth2

+++

### Public provider examples

- [Google Cloud](https://developers.google.com/identity/protocols/OpenIDConnect#authenticatingtheuser)
- [Azure Active Directory](https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-openid-connect-code)

+++

### Private provider examples

- [CoreOS dex](https://github.com/coreos/dex)
- [Keycloack](https://github.com/keycloak/keycloak)
- [Cloud Foundry UAA](https://github.com/cloudfoundry/uaa)

+++

![](https://d33wubrfki0l68.cloudfront.net/d65bee40cabcf886c89d1015334555540d38f12e/c6a46/images/docs/admin/k8s_oidc_login.svg)

+++

### Authentication scenario

1. Login to your identity provider
1. Your identity provider will provide you with an `access_token`, `id_token` and a
`refresh_token`
1. When using kubectl, use your `id_token` with the --token flag or add it directly to your kubeconfig
1. kubectl sends your `id_token` in a header called Authorization to the API server

+++

1. The API server will make sure the JWT signature is valid by checking against the certificate named in the configuration
1. Check to make sure the `id_token` hasn’t expired
1. Make sure the user is authorized
1. Once authorized the API server returns a response to kubectl
1. kubectl provides feedback to the user

+++

Note that Kuberenetes doesn't need to `phone home` while verifying `id_token` -
all the information included in this token and signed by identity provider. This
makes auth solution scalable and stateless.

---

### Useful information

https://kubernetes.io/docs/admin/authentication/

