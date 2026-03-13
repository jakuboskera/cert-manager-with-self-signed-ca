terraform {
  required_version = ">= 1.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.11.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}