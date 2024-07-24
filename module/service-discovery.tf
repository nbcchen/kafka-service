resource "aws_service_discovery_private_dns_namespace" "kafka_namespace" {
  vpc         = var.vpc_id
  description = "Service Discovery Namespace for Kafka Service"
  name        = "kafka.local"
}

resource "aws_service_discovery_service" "kafka_zookeeper_service_discovery_entry" {
  name = "zookeeper"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
  }
  # health_check_config {
  #   failure_threshold = 1
  # }
}

resource "aws_service_discovery_service" "kafka_broker_service_discovery_entry" {
  name = "broker"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}