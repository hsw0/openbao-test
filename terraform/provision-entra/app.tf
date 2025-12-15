
resource "azuread_application_registration" "this" {
  display_name     = "OpenBao local test"
  sign_in_audience = "AzureADMyOrg"

  group_membership_claims        = ["None"]
  requested_access_token_version = 2
}

resource "azuread_application_redirect_uris" "this" {
  application_id = azuread_application_registration.this.id
  type           = "Web"

  redirect_uris = [
    # For local CLI login
    "http://localhost/oidc/callback",

    "http://localhost:8200/ui/vault/auth/admin-oidc/oidc/callback",
    "http://localhost:8200/v1/auth/oidc/oidc/callback",
    "http://localhost:8200/ui/vault/auth/oidc/oidc/callback"
  ]
}

resource "random_uuid" "approle_vault_admin" {}

resource "azuread_application_app_role" "this_admin" {
  application_id = azuread_application_registration.this.id
  role_id        = random_uuid.approle_vault_admin.id

  value                = "vault-admin"
  display_name         = "Vault Admin"
  description          = "Vault Administrator"
  allowed_member_types = ["User"]
}

resource "random_uuid" "approle_default_user" {}

resource "azuread_application_app_role" "this_default_user" {
  application_id = azuread_application_registration.this.id
  role_id        = random_uuid.approle_default_user.id

  value                = "default"
  display_name         = "Vault User"
  description          = "Vault User"
  allowed_member_types = ["User"]
}


resource "azuread_application_api_access" "this_msgraph" {
  application_id = azuread_application_registration.this.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  scope_ids = [
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"],
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"],
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["email"],
    data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"],
  ]
}


resource "azuread_service_principal" "this" {
  client_id = azuread_application_registration.this.client_id

  app_role_assignment_required  = true
  preferred_single_sign_on_mode = "oidc"


  feature_tags {
    enterprise = true
  }
}

resource "azuread_application_password" "this" {
  application_id = azuread_application_registration.this.id
}
