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
}
