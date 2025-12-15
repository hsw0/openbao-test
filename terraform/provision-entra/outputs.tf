
output "entra_app" {
  value = {
    oidc_issuer    = "https://login.microsoftonline.com/${var.entra_tenant_id}/v2.0"
    oidc_client_id = azuread_application_registration.this.client_id
  }
}


output "entra_app_secret" {
  sensitive = true
  value     = azuread_application_password.this.value
}
