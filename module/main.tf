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

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_execution_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "dev-devops-shared"
}

# broker ECR
data "aws_ecr_repository" "kafka_broker_repository" {
  name = var.kafka_broker_ecr_repository
}

data "aws_ecr_image" "kafka_broker_docker_image" {
  repository_name = data.aws_ecr_repository.kafka_broker_repository.name
  most_recent     = true
}

# producer ECR
data "aws_ecr_repository" "kafka_producer_repository" {
  name = var.kafka_producer_ecr_repository
}

data "aws_ecr_image" "kafka_producer_docker_image" {
  repository_name = data.aws_ecr_repository.kafka_producer_repository.name
  most_recent     = true
}

# consumer ECR
data "aws_ecr_repository" "kafka_consumer_repository" {
  name = var.kafka_consumer_ecr_repository
}

data "aws_ecr_image" "kafka_consumer_docker_image" {
  repository_name = data.aws_ecr_repository.kafka_consumer_repository.name
  most_recent     = true
}