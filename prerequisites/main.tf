provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      terraform         = "yes"
      environment       = var.env
      costbucketproject = "kafka"
      costbucket        = "devops"
      application       = "oneapp"
    }
  }
}
