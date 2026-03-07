
resource "vault_policy" "world_user" {
  namespace = vault_namespace.world.path_fq
  name      = "user"

  policy = <<EOT
path "sys/health" {
  capabilities = ["read"]
}

path "sys/namespaces" {
  capabilities = ["list"]
}

path "sys/mounts" {
  capabilities = ["read"]
}

path "sys/tools/+" {
  capabilities = ["update"]
}

path "sys/auth" {
  capabilities = ["read"]
}

path "sys/policies/acl" {
  capabilities = ["list"]
}

path "sys/policies/acl/default" {
  capabilities = ["read"]
}

path "sys/policies/acl/user" {
  capabilities = ["read"]
}

path "identity/entity/id" {
  capabilities = ["list"]
}

path "identity/entity-alias/id" {
  capabilities = ["list"]
}

path "identity/entity/id/{{identity.entity.id}}" {
  capabilities = ["read"]
}

path "identity/entity-alias/id/{{identity.entity.aliases.${vault_jwt_auth_backend.world_oidc.accessor}.id}}" {
  capabilities = ["read"]
}


path "kv/config" {
  capabilities = ["read"]
}

path "kv/metadata" {
  capabilities = ["list"]
}


path "kv/metadata/private" {
  capabilities = ["list", "scan"]
  list_scan_response_keys_filter_path = "{{ .path }}{{ .key }}"
}

path "kv/metadata/private/{{identity.entity.aliases.${vault_jwt_auth_backend.world_oidc.accessor}.name}}/*" {
  capabilities = ["read", "list", "scan"]
}
path "kv/data/private/{{identity.entity.aliases.${vault_jwt_auth_backend.world_oidc.accessor}.name}}/*" {
  capabilities = ["create", "update", "patch", "read", "delete"]
}
EOT
}
