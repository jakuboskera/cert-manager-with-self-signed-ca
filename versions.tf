terraform {
  required_version = ">= 1.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.1.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}