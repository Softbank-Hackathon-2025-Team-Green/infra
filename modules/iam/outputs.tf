output "faas_execution_role_arn" {
  description = "ARN of the FaaS execution role"
  value       = aws_iam_role.faas_execution.arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  value       = aws_iam_role.codebuild.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile for SSM"
  value       = aws_iam_instance_profile.ec2_ssm.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile for SSM"
  value       = aws_iam_instance_profile.ec2_ssm.arn
}
