# SSM Parameters
resource "aws_ssm_parameter" "params" {
  for_each = var.parameters

  name        = "/${var.project_name}/${var.environment}/${each.key}"
  description = each.value.description
  type        = each.value.type
  value       = each.value.value

  tags = merge(
    var.tags,
    {
      Name = each.key
    }
  )
}
