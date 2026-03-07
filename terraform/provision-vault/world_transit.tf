
resource "vault_mount" "world_transit" {
  namespace = vault_namespace.world.path_fq
  path      = "transit"

  type = "transit"
}

resource "vault_generic_endpoint" "world_transit_config" {
  namespace = vault_namespace.world.path_fq
  path      = "${vault_mount.world_transit.id}/config/keys"

  ignore_absent_fields = true
  disable_delete       = true

  data_json = jsonencode({
    disable_upsert = true
  })
}
