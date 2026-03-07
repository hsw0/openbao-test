resource "vault_jwt_auth_backend" "world_oidc" {
  namespace = vault_namespace.world.path_fq
  path      = "oidc"

  type = "oidc"

  oidc_discovery_url  = data.terraform_remote_state.entra.outputs.entra_app.oidc_issuer
  oidc_client_id      = data.terraform_remote_state.entra.outputs.entra_app.oidc_client_id
  oidc_client_secret  = data.terraform_remote_state.entra.outputs.entra_app_secret
  oidc_response_mode  = "query"
  oidc_response_types = ["code"]

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

resource "vault_jwt_auth_backend_role" "world_oidc_user" {
  namespace = vault_namespace.world.path_fq
  backend   = vault_jwt_auth_backend.world_oidc.path
  role_name = "user"

  role_type = "oidc"

  token_no_default_policy = false
  token_policies          = ["user"]

  user_claim   = "preferred_username"
  groups_claim = "roles"
  claim_mappings = {
    "/preferred_username" = "preferred_username"
    "/oid"                = "oid"
    "/sub"                = "sub"
    "/tid"                = "tenant_id"
  }
  oidc_scopes = ["openid", "profile", "email"]
  allowed_redirect_uris = [
    "http://localhost/oidc/callback",
    "http://localhost:8200/ui/vault/auth/${vault_jwt_auth_backend.world_oidc.path}/oidc/callback"
  ]

  #verbose_oidc_logging = false
}


resource "vault_generic_endpoint" "world_oidc_role_user" {
  namespace = vault_namespace.world.path_fq
  path      = vault_jwt_auth_backend_role.world_oidc_user.id

  ignore_absent_fields = true
  disable_delete       = true

  data_json = jsonencode({
    token_policies_template_claims = true

    oauth2_metadata = []
  })
}
