# cert-manager with self-signed CA

Example usage of [cert-manager](http://cert-manager.io), which is using
self-signed CA for issuing TLS certificates as K8s secrets.

These TLS secrets are then used in Ingresses which are consumed by
[ingress-nginx](https://github.com/kubernetes/ingress-nginx).

## TOC

- [cert-manager with self-signed CA](#cert-manager-with-self-signed-ca)
    - [TOC](#toc)
    - [🏁 Get started](#-get-started)
        - [🚀 Create infra](#-create-infra)
        - [Modify /etc/hosts](#modify-etchosts)
        - [Test certificate](#test-certificate)
        - [🧹 Destroy infra](#-destroy-infra)

## 🏁 Get started

### 🚀 Create infra

```bash
make tf-apply
```

### Modify /etc/hosts

```bash
sudo vim /etc/hosts
```

```diff
# /etc/hosts

- 127.0.0.1 localhost
+ 127.0.0.1 localhost app.jakuboskera.local
```

### Test certificate

```bash
openssl s_client \
  -connect app.jakuboskera.local:443 \
  -servername app.jakuboskera.local \
  </dev/null 2>/dev/null \
  | openssl x509 -noout -text \
  | grep DNS: \
  | awk '{$1=$1};1'
open https://app.jakuboskera.local
```

### 🧹 Destroy infra

```bash
make tf-apply
```
