output "security_group_id" {
  description = "Security Group ID for the gateway instance"
  value       = aws_security_group.gateway.id
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.gateway.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.gateway.id
}

output "iam_role_arn" {
  description = "IAM Role ARN for the gateway instance"
  value       = aws_iam_role.gateway.arn
}
