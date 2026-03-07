

resource "vault_generic_endpoint" "sys_config_cors" {
  path                 = "sys/config/cors"
  ignore_absent_fields = true

  data_json = jsonencode({
    enabled         = true
    allowed_origins = ["*"]
  })
}

resource "vault_audit_request_header" "x_forwarded_for" {
  name = "X-Forwarded-For"
  hmac = false
}

resource "vault_audit_request_header" "forwarded" {
  name = "Forwarded"
  hmac = false
}
