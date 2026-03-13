output "app_url" {
  value = "https://${local.host}"
}

output "ca_cert" {
  value     = tls_self_signed_cert.jakuboskera_ca_cert.cert_pem
  sensitive = true
}

output "curl_command" {
  value = "terraform output -raw ca_cert > /tmp/jakuboskera-ca.pem && curl --cacert /tmp/jakuboskera-ca.pem --resolve ${local.host}:443:127.0.0.1 https://${local.host}"
}
