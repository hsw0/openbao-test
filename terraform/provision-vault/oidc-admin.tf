resource "vault_jwt_auth_backend" "admin" {
  type = "oidc"
  path = "admin-oidc"

  description = "Administrators only"

  oidc_discovery_url  = data.terraform_remote_state.entra.outputs.entra_app.oidc_issuer
  oidc_client_id      = data.terraform_remote_state.entra.outputs.entra_app.oidc_client_id
  oidc_client_secret  = data.terraform_remote_state.entra.outputs.entra_app_secret
  oidc_response_mode  = "query"
  oidc_response_types = ["code"]

  default_role = "admin"

  provider_config = {
    provider = "azure"
  }
}

resource "vault_jwt_auth_backend_role" "admin_admin" {
  backend   = vault_jwt_auth_backend.admin.path
  role_type = "oidc"
  role_name = "admin"

  token_policies          = ["superuser", "superuser-handrail"]
  token_no_default_policy = true
  token_explicit_max_ttl  = 3600
  token_type              = "service"

  bound_claims = {
    roles = "vault-admin"
  }
  user_claim = "oid"
  claim_mappings = {
    "/preferred_username" = "preferred_username"
  }
  oidc_scopes = ["openid", "profile", "email"]
  allowed_redirect_uris = [
    "http://localhost/oidc/callback", "http://localhost:8200/ui/vault/auth/admin-oidc/oidc/callback"
  ]
  verbose_oidc_logging = true

}
