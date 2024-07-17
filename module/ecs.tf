resource "aws_ecs_task_definition" "kafka_broker_task" {
  family                   = "kafka-broker-family-${var.env}"
  memory                   = 8192
  cpu                      = 2048
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = [local.launch_type]
  network_mode             = "bridge"
  container_definitions = jsonencode([
    {
      name = "kafka-broker-${var.env}"
      portMappings = [
        {
          containerPort = 9092
          hostPort      = 9092
        }
      ]
      image                    = "bitnami/kafka:2.8.0"
      essential                = true
      readonly_root_filesystem = false
      environment = [
        {
          name  = "KAFKA_BROKER_ID"
          value = "1"
        },
        {
          name  = "KAFKA_ZOOKEEPER_CONNECT"
          value = "1"
        },
        {
          name  = "KAFKA_LISTENERS"
          value = "PLAINTEXT://0.0.0.0:9092"
        },
        {
          name  = "KAFKA_ADVERTISED_LISTENERS"
          value = "PLAINTEXT://kafka:9092"
        }
      ]
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
  ])
}

resource "aws_ecs_service" "kafka_broker_service" {
  name            = "kafka-broker-service-${var.env}"
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  desired_count   = "1"
  launch_type     = local.launch_type
  task_definition = aws_ecs_task_definition.kafka_broker_task.arn
  depends_on = [ aws_ecs_task_definition.kafka_zookeeper_task ]
}

resource "aws_ecs_task_definition" "kafka_zookeeper_task" {
  family                   = "kafka-zookeeper-family-${var.env}"
  memory                   = 8192
  cpu                      = 2048
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = [local.launch_type]
  network_mode             = "bridge"
  container_definitions = jsonencode([
    {
      name = "kafka-zookeeper-${var.env}"
      portMappings = [
        {
          containerPort = 2181
          hostPort      = 2181
        }
      ]
      image                    = "bitnami/kafka:2.8.0"
      essential                = true
      readonly_root_filesystem = false
      environment = [
        {
          name  = "ALLOW_ANONYMOUS_LOGIN"
          value = "yes"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "kafka-zookeeper-"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "kafka_zookeeper_service" {
  name            = "kafka-zookeeper-service-${var.env}"
  cluster         = data.aws_ecs_cluster.cluster.cluster_name
  desired_count   = "1"
  launch_type     = local.launch_type
  task_definition = aws_ecs_task_definition.kafka_zookeeper_task.arn
}

# resource "aws_ecs_task_definition" "kafka_consumer_task" {
#   family                   = "kafka-consumer-family-${var.env}"
#   memory                   = 8192
#   cpu                      = 2048
#   execution_role_arn       = aws_iam_role.ecs_execution_role.arn
#   requires_compatibilities = [local.launch_type]
#   network_mode             = "bridge"
#   container_definitions = jsonencode([
#     {
#       name = "kafka-consumer-${var.env}"
#       image                    = data.aws_ecr_image.kafka_consumer_docker_image
#       essential                = true
#       readonly_root_filesystem = false
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-create-group"  = "true"
#           "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
#           "awslogs-region"        = "us-east-1"
#           "awslogs-stream-prefix" = "kafka-consumer-"
#         }
#       }
#     }
#   ])
# }

# resource "aws_ecs_service" "kafka_consumer_service" {
#   name            = "kafka-consumer-service-${var.env}"
#   cluster         = data.aws_ecs_cluster.cluster.cluster_name
#   desired_count   = "1"
#   launch_type     = local.launch_type
#   task_definition = aws_ecs_task_definition.kafka_consumer_task.arn
#   depends_on = [ aws_ecs_task_definition.kafka_broker_task ]
# }
