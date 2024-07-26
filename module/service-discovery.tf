resource "aws_service_discovery_private_dns_namespace" "kafka_namespace" {
  vpc         = var.vpc_id
  description = "Service Discovery Namespace for Kafka Service"
  name        = "kafka-pubsub.local"
}

resource "aws_service_discovery_service" "kafka_zookeeper_service_discovery_entry" {
  description = "Kakfa zookeeper DNS"
  name        = "zookeeper"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "kafka_broker_service_discovery_entry" {
  description = "kafka broker service discovery entry in Cloud Map"
  name        = "kafka"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka_namespace.id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
