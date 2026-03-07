

resource "vault_generic_endpoint" "sys_config_cors" {
  path                 = "sys/config/cors"
  ignore_absent_fields = true

  data_json = jsonencode({
    enabled         = true
    allowed_origins = ["*"]
  })
}
