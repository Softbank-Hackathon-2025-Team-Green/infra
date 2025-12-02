resource "aws_amplify_app" "main" {
  count = var.repository_url != "" ? 1 : 0

  name       = "${var.project_name}-${var.environment}"
  repository = var.repository_url

  access_token = var.access_token

  build_spec = var.build_spec != "" ? var.build_spec : <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  environment_variables = {
    ENV = var.environment
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

  enable_auto_build = true

  tags = var.tags
}

resource "aws_amplify_branch" "develop" {
  count = var.repository_url != "" ? 1 : 0

  app_id      = aws_amplify_app.main[0].id
  branch_name = var.dev_branch_name

  enable_auto_build = true

  tags = var.tags
}

