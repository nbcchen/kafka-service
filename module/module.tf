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

locals {
  launch_type = "FARGATE"
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

# data "aws_iam_policy_document" "apprunner_assume_role_policy" {
#   version = "2012-10-17"
#   statement {
#     principals {
#       type        = "Service"
#       identifiers = [
#         "build.apprunner.amazonaws.com",
#         "tasks.apprunner.amazonaws.com"
#       ]
#     }
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#   }
# }

data "aws_iam_policy_document" "ecs_execution_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "servicediscovery:DiscoverInstances"
    ]
    resources = ["*"]
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

# producer ECR
data "aws_ecr_repository" "kafka_producer_repository" {
  name = "kafka-producer-ecr-repo-${var.env}"
}

data "aws_ecr_image" "kafka_producer_docker_image" {
  repository_name = data.aws_ecr_repository.kafka_producer_repository.name
  most_recent     = true
}

# consumer ECR
data "aws_ecr_repository" "kafka_consumer_repository" {
  name = "kafka-consumer-ecr-repo-${var.env}"
}

data "aws_ecr_image" "kafka_consumer_docker_image" {
  repository_name = data.aws_ecr_repository.kafka_consumer_repository.name
  most_recent     = true
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "AWSAppRunnerServicePolicyForECRAccess" {
  name = "AWSAppRunnerServicePolicyForECRAccess"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}
