variable "env" {
  type    = string
  default = "dev"
}

variable "kafka_broker_ecr_repository" {
  type = string
}

variable "kafka_producer_ecr_repository" {
  type = string
}

variable "kafka_consumer_ecr_repository" {
  type = string
}
