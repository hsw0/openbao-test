resource "vault_mount" "world_kv" {
  namespace = vault_namespace.world.path_fq
  path      = "kv"

  type    = "kv"
  options = { version = "2" }
}

resource "vault_kv_secret_backend_v2" "world_kv" {
  namespace = vault_namespace.world.path_fq
  mount     = vault_mount.world_kv.path

  max_versions         = 10
  delete_version_after = 604800
}
