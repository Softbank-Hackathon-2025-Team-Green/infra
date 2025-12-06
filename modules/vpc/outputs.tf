output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# multi-az
output "public_subnet_ids" {
  description = "List of public subnet IDs (primary + optional additional)"
  value = compact([
    aws_subnet.public.id,
    length(aws_subnet.public_additional) > 0 ? aws_subnet.public_additional[0].id : null
  ])
}


output "private_subnet_ids" {
  description = "List of private subnet IDs (primary + optional additional)"
  value = compact([
    aws_subnet.private.id,
    length(aws_subnet.private_additional) > 0 ? aws_subnet.private_additional[0].id : null
  ])
}
