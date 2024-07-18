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
  source = "../module"
  cluster_name = var.cluster_name
  container_subnet_ids = var.container_subnet_ids
  vpc_id = var.vpc_id
}
