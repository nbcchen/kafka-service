terraform {
  backend "s3" {
    bucket  = "terrarium-tfstates-envs"
    key     = "kafka-poc/dev/terraform.tfstate"
    encrypt = true
    region  = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      terraform         = "yes"
      environment       = var.env
      costbucketproject = "kafka-poc"
      costbucket        = "koco"
      application       = "oneapp"
    }
  }
}
module "kafka-service" {
  source                      = "../module"
  kafka_broker_ecr_repository = aws_ecr_repository.kafka_broker_repository.name
  kafka_consumer_ecr_repository = aws_ecr_repository.kafka_consumer_repository.name
  kafka_producer_ecr_repository = aws_ecr_repository.kafka_producer_repository.name
}
