provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      terraform         = "yes"
      application       = "oneapp"
      environment       = var.env
      costbucket        = "devops"
      costbucketproject = "kafka"
    }
  }
}
