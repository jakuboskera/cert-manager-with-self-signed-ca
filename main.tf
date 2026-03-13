locals {
  host = "app.jakuboskera.local"
}

resource "kind_cluster" "my-cluster" {
  name           = "my-cluster"
  wait_for_ready = "true"
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:v1.35.1"

      extra_port_mappings {
        container_port = 32080
        host_port      = 80
      }

      extra_port_mappings {
        container_port = 32443
        host_port      = 443
      }
    }
  }
}

resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  version          = "39.0.5"
  create_namespace = true
  atomic           = true
  values = [<<EOF
service:
  type: NodePort
ports:
  web:
    nodePort: 32080
  websecure:
    nodePort: 32443
EOF
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.20.0"
  create_namespace = true
  atomic           = true
  set = [{
    name  = "crds.enabled"
    value = "true"
  }]
}

resource "helm_release" "podinfo" {
  name       = "podinfo"
  repository = "https://stefanprodan.github.io/podinfo"
  chart      = "podinfo"
  namespace  = "default"
  version    = "6.11.0"
  atomic     = true
  values = [<<-YAML
ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: jakuboskera-ca
  hosts:
  - host: ${local.host}
    paths:
    - path: /
      pathType: ImplementationSpecific
  tls:
  - secretName: ${replace(local.host, ".", "-")}-tls
    hosts:
    - ${local.host}
YAML
  ]
}

resource "tls_private_key" "jakuboskera_ca_private_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "jakuboskera_ca_cert" {
  private_key_pem = tls_private_key.jakuboskera_ca_private_key.private_key_pem

  is_ca_certificate = true

  subject {
    country             = "CZ"
    common_name         = "Jakub Oskera Root CA"
    organization        = "Jakub Oskera"
    organizational_unit = "Jakub Oskera Root Certification Auhtority"
  }

  validity_period_hours = 43800 //  1825 days or 5 years

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "kubernetes_secret_v1" "jakuboskera_ca" {
  metadata {
    name      = "jakuboskera-ca"
    namespace = helm_release.cert_manager.namespace
  }

  data = {
    "tls.crt" = tls_self_signed_cert.jakuboskera_ca_cert.cert_pem
    "tls.key" = tls_private_key.jakuboskera_ca_private_key.private_key_pem
  }

  type = "kubernetes.io/tls"
}

resource "kubectl_manifest" "cluster_issuer_jakuboskera_ca" {
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: jakuboskera-ca
spec:
  ca:
    secretName: ${kubernetes_secret_v1.jakuboskera_ca.metadata[0].name}
YAML
  depends_on = [helm_release.cert_manager]
}
