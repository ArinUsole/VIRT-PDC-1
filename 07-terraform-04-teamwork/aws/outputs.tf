output "aws_caller_identity-account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_identity-user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_region-name" {
  value = data.aws_region.current.name
}

output "app_server-private_ip" {
  value       = aws_instance.app_server.private_ip
}

output "app_server-subnet_id" {
  value       = aws_instance.app_server.subnet_id
}
