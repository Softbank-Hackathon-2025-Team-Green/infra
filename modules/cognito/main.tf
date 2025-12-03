# ============================================
# Cognito User Pool
# ============================================
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-${var.environment}-user-pool"

  # Allow sign-in with email
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # User attribute schema
  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # MFA configuration (optional)
  mfa_configuration = var.mfa_configuration

  # Deletion protection
  deletion_protection = var.deletion_protection ? "ACTIVE" : "INACTIVE"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-user-pool"
    }
  )
}

# ============================================
# Cognito User Pool Domain
# ============================================
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-${var.environment}-${var.domain_suffix}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# ============================================
# Cognito User Pool Client
# ============================================
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-${var.environment}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # OAuth configuration
  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  supported_identity_providers = concat(
    ["COGNITO"],
    var.enable_google_provider ? ["Google"] : []
  )

  # Token validity
  refresh_token_validity = 30
  access_token_validity  = 60
  id_token_validity      = 60

  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read and write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name",
    "picture",
  ]

  write_attributes = [
    "email",
    "name",
    "picture",
  ]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

# ============================================
# Google Identity Provider (Conditional)
# ============================================
resource "aws_cognito_identity_provider" "google" {
  count = var.enable_google_provider ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email openid profile"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
    picture  = "picture"
  }

  lifecycle {
    ignore_changes = [
      provider_details["attributes_url"],
      provider_details["attributes_url_add_attributes"],
      provider_details["authorize_url"],
      provider_details["oidc_issuer"],
      provider_details["token_request_method"],
      provider_details["token_url"],
    ]
  }
}
