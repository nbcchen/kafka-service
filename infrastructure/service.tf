module "kafka-service" {
  source = "../module"
  cluster_name = var.cluster_name
  container_subnet_ids = var.container_subnet_ids
  vpc_id = var.vpc_id
}
