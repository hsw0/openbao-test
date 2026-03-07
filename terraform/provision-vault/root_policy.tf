
resource "vault_policy" "root_superuser" {
  name = "superuser"

  policy = <<EOT
path "*" {
  capabilities = ["create", "update", "patch", "delete", "read", "list", "scan", "sudo"]
}

path "sys/audit/+" {
  capabilities = ["read", "list", "scan"]
}
EOT
}


# Don't shoot yourself!
resource "vault_policy" "root_superuser_handrail" {
  name = "superuser-handrail"

  policy = <<EOT
path "sys/policies/acl/superuser" {
  capabilities = ["read", "list", "scan"]
}
path "sys/policies/acl/superuser-handrail" {
  capabilities = ["read", "list", "scan"]
}

path "identity/entity/id/{{identity.entity.id}}" {
  capabilities = ["read", "update", "patch"]
  denied_parameters = {
    "disabled" = [true]
    "policies" = []
  }
}
path "identity/entity-alias/id/{{identity.entity.aliases.${vault_jwt_auth_backend.root_oidc.accessor}.id}}" {
  capabilities = ["read"]
}

path "sys/seal" {
  capabilities = ["deny"]
}
path "sys/auth/token" {
  capabilities = ["read", "list", "scan", "sudo"]
}
path "sys/auth/admin-oidc" {
  capabilities = ["read", "list", "scan"]
}
path "auth/token" {
  capabilities = ["read", "list", "scan"]
}
path "auth/admin-oidc/*" {
  capabilities = ["read", "list", "scan"]
}
EOT
}
