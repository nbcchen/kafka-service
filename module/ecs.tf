resource "aws_ecs_task_definition" "kafka_service_task" {
  family                   = "kafka-service-family-${var.env}"
  memory                   = 8192
  cpu                      = 2048
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
    requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  container_definitions = jsonencode([
    {
      name      = "kafka-broker-${var.env}"
      image     = "${data.aws_ecr_image.kafka_broker_docker_image.image_uri}"
      essential = true
      readonly_root_filesystem = false
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "kafka-broker-"
        }
      }
    }
    # add producer and consumer here
  ])
}

resource "aws_ecs_service" "kafka_service" {
  name            = "kafka-service-${var.env}"
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  desired_count   = "1"
  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.kafka_service_task
}
