dev = false

log_level = "debug"
log_format = "json"

ui = true
enable_response_header_hostname = true

api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"

listener "tcp" {
  address = "[::]:8200"
  cluster_address = "[::]:8201"
  tls_disable = true
}

storage "raft" {
  path = "/openbao/data"
  node_id = "node-0"
}

seal "awskms" {
  kms_key_id = "5b1121d8-a941-4deb-a244-c8388bbab019"
}

audit "file" "default" {
  options {
    file_path = "/openbao/logs/audit.log.json"
    format = "json"
  }
}

plugin_directory = "/openbao/plugins"
plugin_auto_download = true
plugin_auto_register = true
plugin_download_behavior = "fail"

plugin "secret" "consul" {
  image       = "ghcr.io/openbao/openbao-plugin-secrets-consul"
  version     = "v0.1.0"
  binary_name = "openbao-plugin-secrets-consul"
  sha256sum   = "16e6a508fef825699e61fb44d66c28287664aac4b9f635fec0b25fd518d5fb5d"
}

plugin "secret" "aws" {
  image       = "ghcr.io/openbao/openbao-plugin-secrets-aws"
  version     = "v0.2.0"
  binary_name = "openbao-plugin-secrets-aws"
  sha256sum   = "991732feb606737baf727cba0ffa99def84f440d50c21c12ff0c4e7c5bdcc0f1"
}

plugin "auth" "aws" {
  image       = "ghcr.io/openbao/openbao-plugin-auth-aws"
  version     = "v0.1.1"
  binary_name = "openbao-plugin-auth-aws"
  sha256sum   = "3b03fb12b8cedd9d2d83ea282a32a4f70147c93a927af5937c9b081525830db2"
}

plugin "secret" "gcp" {
  image       = "ghcr.io/openbao/openbao-plugin-secrets-gcp"
  version     = "v0.23.0"
  binary_name = "openbao-plugin-secrets-gcp"
  sha256sum   = "6d8af574467bc075f524cd3c2f1a1ee2f529be71618f81795e9fec3669ba6182"
}

plugin "auth" "gcp" {
  image       = "ghcr.io/openbao/openbao-plugin-auth-gcp"
  version     = "v0.22.0"
  binary_name = "openbao-plugin-auth-gcp"
  sha256sum   = "6e0c51281ca6f2b2c6818070397059e8522b2f071e17b18db37607c7d505a8c1"
}
