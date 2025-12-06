output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the first public subnet"
  value       = element([for s in aws_subnet.public : s.id], 0)
}

output "public_subnet_ids" {
  description = "IDs of all public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_id" {
  description = "ID of the first private subnet"
  value       = element([for s in aws_subnet.private : s.id], 0)
}

output "private_subnet_ids" {
  description = "IDs of all private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = try(aws_nat_gateway.main[0].id, null)
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
