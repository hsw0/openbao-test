api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://127.0.0.1:8201"

log_level = "debug"

ui = true
enable_response_header_hostname = true

listener "tcp" {
  address = "[::]:8200"
  tls_disable = true

  disable_unauthed_rekey_endpoints = true
}

storage "raft" {
  path = "/openbao/data"
  node_id = "node-0"
}

seal "awskms" {
  kms_key_id = "5b1121d8-a941-4deb-a244-c8388bbab019"
}
