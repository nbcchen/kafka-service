output "kafka_producer_repository_url" {
  value = aws_ecr_repository.kafka_producer_repository.repository_url
}

output "kafka_consumer_repository_url" {
  value = aws_ecr_repository.kafka_consumer_repository.repository_url
}

output "kafka_producer_repository" {
  value = aws_ecr_repository.kafka_producer_repository.name
}

output "kafka_consumer_repository" {
  value = aws_ecr_repository.kafka_consumer_repository.name
}
