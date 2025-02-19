output "arn" {
  description = "Service discovery arn"
  value       = aws_service_discovery_service.discovery_service.arn
}