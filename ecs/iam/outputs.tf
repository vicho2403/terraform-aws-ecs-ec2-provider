output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.iam_role.arn
}

output "role_name" {
  description = "IAM role Name"
  value       = aws_iam_role.iam_role.name
}