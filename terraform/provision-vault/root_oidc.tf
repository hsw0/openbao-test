resource "vault_jwt_auth_backend" "root_oidc" {
  namespace = null
  path      = "oidc"

  type = "oidc"

  oidc_discovery_url  = data.terraform_remote_state.entra.outputs.entra_app.oidc_issuer
  oidc_response_mode  = "query"
  oidc_response_types = ["code"]

  oidc_client_id                = data.terraform_remote_state.entra.outputs.entra_app.oidc_client_id
  oidc_client_secret_wo         = data.terraform_remote_state.entra.outputs.entra_app_secret
  oidc_client_secret_wo_version = parseint(substr(sha256(data.terraform_remote_state.entra.outputs.entra_app_secret), 0, 6), 16)

  disable_remount = true
  default_role    = "user"

  tune {
    listing_visibility = "unauth"
    token_type         = "service"
  }

  provider_config = {
    provider = "azure"
  }
}

resource "vault_jwt_auth_backend_role" "root_oidc_admin" {
  namespace = null
  backend   = vault_jwt_auth_backend.root_oidc.path
  role_name = "admin"

  role_type = "oidc"

  token_no_default_policy = true
  token_policies = [
    vault_policy.root_superuser.id,
    vault_policy.root_superuser_handrail.id,
  ]

  token_explicit_max_ttl = 3600
  token_type             = "service"

  bound_claims = {
    roles = "vault-admin"
  }
  user_claim = "preferred_username"
  claim_mappings = {
    "/preferred_username" = "preferred_username"

    "/sid" = "sid"
    "/sub" = "sub"
    "tid"  = "tenant_id"
    "oid"  = "object_id"
  }
  oidc_scopes = ["openid", "profile", "email"]
  allowed_redirect_uris = [
    "http://localhost/oidc/callback",
    "http://localhost:8200/ui/vault/auth/${vault_jwt_auth_backend.root_oidc.path}/oidc/callback"
  ]

  #verbose_oidc_logging = false
}
