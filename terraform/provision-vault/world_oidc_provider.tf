resource "vault_identity_oidc_key" "test" {
  namespace = vault_namespace.world.path_fq
  name      = "my-key"

  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 3600
}

resource "vault_identity_oidc_assignment" "test" {
  namespace = vault_namespace.world.path_fq
  name      = "my-assignment"

  entity_ids = ["fake-ascbascas-2231a-sdfaa"]
  group_ids  = ["fake-sajkdsad-32414-sfsada"]
}

resource "vault_identity_oidc_client" "test" {
  namespace = vault_namespace.world.path_fq
  name      = "application"

  key = vault_identity_oidc_key.test.name

  redirect_uris = [
    "http://127.0.0.1:9200/v1/auth-methods/oidc:authenticate:callback",
    "http://127.0.0.1:8251/callback",
    "http://127.0.0.1:8080/callback"
  ]
  assignments = [
    vault_identity_oidc_assignment.test.name
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_identity_oidc_scope" "test" {
  namespace = vault_namespace.world.path_fq
  name      = "groups"

  template = jsonencode(
    {
      groups = "{{identity.entity.groups.names}}",
    }
  )
  description = "Groups scope."
}

resource "vault_identity_oidc_provider" "test" {
  namespace = vault_namespace.world.path_fq
  name      = "default"

  https_enabled      = false
  issuer_host        = "localhost:8200"
  allowed_client_ids = ["*"]
  scopes_supported = [
    vault_identity_oidc_scope.test.name
  ]
}
