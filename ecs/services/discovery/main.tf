# ----------------------------------------------------------------------------------------------------------------------
# Service Discovery Service
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_service_discovery_service" "discovery_service" {
  name         = var.name
  namespace_id = var.private_namespace_id

  dns_config {
    namespace_id = var.private_namespace_id

    dns_records {
      ttl  = var.ttl
      type = var.type
    }
  }
}