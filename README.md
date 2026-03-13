# cert-manager with self-signed CA

Example usage of [cert-manager](http://cert-manager.io), which is using
self-signed CA for issuing TLS certificates as K8s secrets.

These TLS secrets are then used in Ingresses which are consumed by
[Traefik](https://traefik.io/traefik/).

## TOC

- [cert-manager with self-signed CA](#cert-manager-with-self-signed-ca)
  - [TOC](#toc)
  - [🏁 Get started](#-get-started)
    - [🚀 Create infra](#-create-infra)
    - [Test with curl](#test-with-curl)
    - [Test certificate](#test-certificate)
    - [🧹 Destroy infra](#-destroy-infra)

## 🏁 Get started

### 🚀 Create infra

```bash
make tf-apply
```

### Test with curl

Use the generated CA certificate to verify the TLS connection:

```bash
eval "$(terraform output -raw curl_command)"
```

### Test certificate

```bash
openssl s_client \
  -connect 127.0.0.1:443 \
  -servername app.jakuboskera.local \
  </dev/null 2>/dev/null \
  | openssl x509 -noout -text \
  | grep -E 'Issuer:|DNS:' \
  | awk '{$1=$1};1'
```

### 🧹 Destroy infra

```bash
make tf-destroy
```
