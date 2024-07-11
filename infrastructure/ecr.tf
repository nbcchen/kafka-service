resource "aws_ecr_repository" "kafka_broker_repository" {
  name = "kafka-broker-ecr-repo-${var.env}"
}

resource "aws_ecr_repository" "kafka_producer_repository" {
  name = "kafka-producer-ecr-repo-${var.env}"
}

resource "aws_ecr_repository" "kafka_consumer_repository" {
  name = "kafka-consumer-ecr-repo-${var.env}"
}
