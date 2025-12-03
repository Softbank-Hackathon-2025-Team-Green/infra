resource "aws_amplify_app" "main" {
  count = var.repository_url != "" ? 1 : 0

  name       = "${var.project_name}-${var.environment}"
  repository = var.repository_url

  access_token = var.access_token

  iam_service_role_arn = var.service_role_arn != "" ? var.service_role_arn : null
  compute_role_arn     = var.compute_role_arn != "" ? var.compute_role_arn : null

  platform = var.platform

  build_spec = var.build_spec != "" ? var.build_spec : <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci --cache .npm --prefer-offline --legacy-peer-deps
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - .next/cache/**/*
          - .npm/**/*

  EOT

  environment_variables = merge(
    {
      ENV = var.environment
    },
    var.environment_variables
  )

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-amplify"
    }
  )
}

resource "aws_amplify_branch" "master" {
  count = var.repository_url != "" ? 1 : 0

  app_id      = aws_amplify_app.main[0].id
  branch_name = var.branch_name
  framework   = var.framework

  enable_auto_build = true

  tags = var.tags
}

resource "aws_amplify_branch" "develop" {
  count = var.repository_url != "" ? 1 : 0

  app_id      = aws_amplify_app.main[0].id
  branch_name = var.dev_branch_name
  framework   = var.framework

  enable_auto_build = true

  tags = var.tags
}

