resource "aws_ecs_task_definition" "kafka_broker_task" {
  family             = "kafka-service-family-${var.env}"
  memory             = 8192
  cpu                = 2048
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "kafka-service"
      image = "${data.aws_ecr_image.kafka_broker_docker_image.image_uri}"
    }
  ])
}

resource "aws_ecs_service" "kafka_broker" {
  name            = "kafka-service-${var.env}"
  depends_on      = [aws_iam_role_policy.ecs_policy]
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  desired_count   = "1"
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.kafka_broker_task
}
