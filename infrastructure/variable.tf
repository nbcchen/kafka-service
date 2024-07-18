variable "env" {
  type    = string
  default = "dev"
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
  validation {
    condition = length(var.vpc_id) > 4 && substr(var.vpc_id, 0, 4) == "vpc-"
    error_message = "vpc_id is not valid"
  }
}

variable "container_subnet_ids" {
  type = list(string)
  validation {
    condition = alltrue([
      for v in var.container_subnet_ids : length(v) > 7 && substr(v, 0, 7) == "subnet-"
    ])
    error_message = "At least 1 subnet ID is not valid"
  }
}
