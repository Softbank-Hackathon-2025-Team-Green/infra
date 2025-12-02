output "app_id" {
  description = "ID of the Amplify app"
  value       = var.repository_url != "" ? aws_amplify_app.main[0].id : null
}

output "default_domain" {
  description = "Default domain for the Amplify app"
  value       = var.repository_url != "" ? aws_amplify_app.main[0].default_domain : null
}
