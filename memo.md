# memo

## Initialize
```bash
VAULT_ADDR=http://localhost:8200 bao operator init
```

```
Recovery Key 1: m3Ns0dbcWhorYPbWD+k/UXpV4b53gwj/8FoDMdg6f5Jr
Recovery Key 2: dIVeQc5EoY/2wWc91W0sKuTmAc6mwSSkng9HoqtvcfmD
Recovery Key 3: CD8TtDTxWWa0nSTkZeaupVO0b4EQrPWIbOc5qGs7je2n
Recovery Key 4: 25+yTZeFV4RQPAPuIvhhZv8rANuEzMK8SjalbTl1cuqk
Recovery Key 5: 7QQAMERfgllpJdl2T9aDA+NWkSFU6IvdRJKn6FJUDvRc

Initial Root Token: s.EqWokxTuwSEhp3cDaJKwbAvX

Success! Vault is initialized

Recovery key initialized with 5 key shares and a key threshold of 3. Please
securely distribute the key shares printed above.
```

```
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN='s.EqWokxTuwSEhp3cDaJKwbAvX'
```

## first setup

```bash
bao policy write superuser -<<"EOF"
path "*" {
  capabilities = ["create", "update", "patch", "delete", "read", "list", "scan", "sudo"]
}

path "sys/audit/+" {
  capabilities = ["read", "list", "scan"]
}
EOF
```

```bash
bao policy write superuser-handrail -<<"EOF"
# Don't shoot yourself!

path "sys/policies/acl/superuser" {
  capabilities = ["read", "list", "scan"]
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

EOF
```

```bash
bao write sys/config/cors -<<"EOF"
{
  "enabled": true,
  "allowed_origins": ["*"]
}
EOF
```

```bash
bao auth enable -path=admin-oidc oidc

bao write auth/admin-oidc/config -<<"EOF"
{
  "oidc_discovery_url": "https://login.microsoftonline.com/00000000-0000-0000-YOURTENANTID/v2.0",
  "oidc_client_id": "00000000-0000-0000-YOURAPPCLIENTID",
  "oidc_client_secret": "<REDACTED>",
  "oidc_response_mode": "query",
  "oidc_response_types": ["code"],
  "default_role": "admin",

  "provider_config": {
     "provider": "azure"
  }
}
EOF

bao write auth/admin-oidc/role/admin -<<"EOF"
{
  "token_policies": ["superuser", "superuser-handrail"],
  "token_policies_template_claims": true,
  "token_no_default_policy": true,
  "token_explicit_max_ttl": "1h",
  "token_type": "service",

  "user_claim": "oid",
  "bound_claims": {
    "roles": ["vault-admin"]
  },
  "claim_mappings": {
    "/preferred_username": "preferred_username"
  },
  "oidc_scopes": ["profile"],
  "allowed_redirect_uris": ["http://localhost/oidc/callback", "http://localhost:8200/ui/vault/auth/admin-oidc/oidc/callback"],
  "verbose_oidc_logging": true
}
EOF
```

```bash
bao login -method=oidc

bao token lookup
```

```bash
bao namespace create world

bao auth enable -namespace=world oidc
bao write -namespace=world sys/auth/oidc/tune listing_visibility="unauth"
```


```bash
bao write -namespace=world auth/oidc/config -<<"EOF"
{
  "oidc_discovery_url": "https://login.microsoftonline.com/00000000-0000-0000-YOURTENANTID/v2.0",
  "oidc_client_id": "00000000-0000-0000-YOURAPPCLIENTID",
  "oidc_client_secret": "<REDACTED>",
  "oidc_response_mode": "query",
  "oidc_response_types": ["code"],
  "default_role": "default-user",

  "provider_config": {
     "provider": "azure"
  }
}
EOF


bao write -namespace=world auth/oidc/role/default-user -<<"EOF"
{
  "token_policies": ["default-user", "user/{{.preferred_username}}"],
  "token_policies_template_claims": true,
  "token_ttl": "4h",
  "token_max_ttl": "36h",
  "token_type": "service",

  "user_claim": "preferred_username",
  "groups_claim": "roles",
  "claim_mappings": {
    "/oid": "objectId",
    "/tid": "tenantId"
  },
  "oidc_scopes": ["profile"],
  "allowed_redirect_uris": ["http://localhost/oidc/callback", "http://localhost:8200/ui/vault/auth/oidc/oidc/callback"],
  "verbose_oidc_logging": true
}
EOF
```


```bash
bao policy write -namespace=world default-user -<<"EOF"
path "sys/health" {
  capabilities = ["read"]
}

path "sys/mounts" {
  capabilities = ["read"]
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

path "sys/policies/acl/default-user" {
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

path "identity/entity-alias/id/{{identity.entity.aliases.auth_oidc_d69fd34e.id}}" {
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

path "kv/metadata/private/{{identity.entity.aliases.auth_oidc_d69fd34e.name}}/*" {
  capabilities = ["read", "list", "scan"]
}
path "kv/data/private/{{identity.entity.aliases.auth_oidc_d69fd34e.name}}/*" {
  capabilities = ["create", "update", "patch", "read", "delete"]
}

EOF
```


```bash
bao secrets enable -namespace=world -version=2 kv

bao kv put  -namespace=world  kv/test/path1/path2/path3/path4 foo=a bar=b
```
