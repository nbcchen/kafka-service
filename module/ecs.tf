resource "aws_ecs_task_definition" "kafka_broker_task" {
  family                   = "kafka-broker-family-${var.env}"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = [local.launch_type]
  network_mode             = "awsvpc"
  depends_on               = [aws_ecs_service.kafka_zookeeper_service]
  container_definitions = jsonencode([
    {
      name = "Kafka_ResolvConf_InitContainer"
      command = [
        "us-east-1.compute.internal",
        "kafka-pubsub.local"
      ],
      essential : false
      image : "docker/ecs-searchdomain-sidecar:1.0"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "kafka-broker-sidecar-"
        }
      }
    },
    {
      depends_on = [
        {
          conition       = "SUCCESS"
          container_name = "Kafka_ResolvConf_InitContainer"
        }
      ]
      name = "kafka-broker-${var.env}"
      portMappings = [
        {
          containerPort = 9092
          hostPort      = 9092
        }
      ]
      image                    = "public.ecr.aws/bitnami/kafka:2.8.0"
      essential                = true
      readonly_root_filesystem = false
      environment = [
        {
          name  = "KAFKA_BROKER_ID"
          value = "1"
        },
        {
          name  = "KAFKA_ZOOKEEPER_CONNECT"
          value = "zookeeper.kafka.local:2181"
        },
        {
          name  = "KAFKA_LISTENERS"
          value = "PLAINTEXT://0.0.0.0:9092"
        },
        {
          name  = "KAFKA_ADVERTISED_LISTENERS"
          value = "PLAINTEXT://broker.kafka.local:9092"
        },
        {
          name  = "ALLOW_PLAINTEXT_LISTENER"
          value = "yes"
        },
        # https://github.com/bitnami/charts/issues/16188
        {
          name  = "KAFKA_CFG_LISTENERS"
          value = "PLAINTEXT://:9092"
        },
        {
          name  = "KAFKA_CFG_ADVERTISED_LISTENERS"
          value = "PLAINTEXT://127.0.0.1:9092"
        },
        {
          name  = "KAFKA_CFG_ZOOKEEPER_CONNECT"
          value = "zookeeper.kafka.local:2181"
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
  deployment_controller {
    type = "ECS"
  }
  network_configuration {
    subnets          = var.container_subnet_ids
    assign_public_ip = true
    security_groups = [
      aws_security_group.kafka_broker_sg.id
    ]
  }
  platform_version                   = "1.4.0"
  propagate_tags                     = "SERVICE"
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  service_registries {
    registry_arn = aws_service_discovery_service.kafka_broker_service_discovery_entry.arn
  }
}

resource "aws_ecs_task_definition" "kafka_zookeeper_task" {
  family                   = "kafka-zookeeper-family-${var.env}"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = [local.launch_type]
  network_mode             = "awsvpc"
  container_definitions = jsonencode([
    {
      name = "Zookeeper_ResolvConf_InitContainer"
      command = [
        "us-east-1.compute.internal",
        "kafka-pubsub.local"
      ]
      essential = false
      image     = "docker/ecs-searchdomain-sidecar:1.0"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "kafka-zookeeper-sidecar-"
        }
      }
    },
    {
      name = "kafka-zookeeper-${var.env}"
      portMappings = [
        {
          containerPort = 2181
          hostPort      = 2181
        }
      ]
      image                    = "public.ecr.aws/bitnami/zookeeper:3.7.0"
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
  service_registries {
    registry_arn = aws_service_discovery_service.kafka_zookeeper_service_discovery_entry.arn
  }
  deployment_controller {
    type = "ECS"
  }
  platform_version                   = "1.4.0"
  propagate_tags                     = "SERVICE"
  scheduling_strategy                = "REPLICA"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  network_configuration {
    subnets          = var.container_subnet_ids
    assign_public_ip = true
    security_groups = [
      aws_security_group.kafka_zookeeper_sg.id
    ]
  }
}

resource "aws_ecs_task_definition" "kafka_consumer_task" {
  family                   = "kafka-consumer-family-${var.env}"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = [local.launch_type]
  network_mode             = "awsvpc"
  depends_on = [
    # aws_ecs_service.kafka_broker_service,
    # aws_ecs_task_definition.kafka_broker_task
  ]
  container_definitions = jsonencode([
    {
      name                     = "kafka-consumer-${var.env}"
      image                    = data.aws_ecr_image.kafka_consumer_docker_image.image_uri
      essential                = true
      readonly_root_filesystem = false
      environment = [
        {
          name  = "KAFKA_BROKER_HOST"
          value = "broker.kafka.local"
        },
        {
          name  = "AWS_REGION",
          value = "us-east-1"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "kafka-consumer-"
        }
      }
    }
  ])
}

# resource "aws_ecs_service" "kafka_consumer_service" {
#   name            = "kafka-consumer-service-${var.env}"
#   cluster         = data.aws_ecs_cluster.cluster.cluster_name
#   desired_count   = "1"
#   launch_type     = local.launch_type
#   task_definition = aws_ecs_task_definition.kafka_consumer_task.arn
#   network_configuration {
#     subnets = var.container_subnet_ids
#     security_groups = [
#       aws_security_group.kafka_consumer_sg.id
#     ]
#   }
# }

# resource "aws_ecs_task_definition" "kafka_producer_task" {
#   family                   = "kafka-producer-family-${var.env}"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn       = aws_iam_role.ecs_execution_role.arn
#   requires_compatibilities = [local.launch_type]
#   network_mode             = "awsvpc"
#   container_definitions = jsonencode([
#     {
#       name                     = "kafka-producer-${var.env}"
#       image                    = data.aws_ecr_image.kafka_producer_docker_image.image_uri
#       essential                = true
#       readonly_root_filesystem = false
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           "awslogs-create-group"  = "true"
#           "awslogs-group"         = aws_cloudwatch_log_group.kafka_log_group.name
#           "awslogs-region"        = "us-east-1"
#           "awslogs-stream-prefix" = "kafka-producer-"
#         }
#       }
#     }
#   ])
#   depends_on = [
#     # aws_ecs_service.kafka_broker_service,
#     aws_ecs_task_definition.kafka_consumer_task,
#     # aws_ecs_service.kafka_consumer_service,
#     aws_iam_role.ecs_execution_role
#   ]
# }

# resource "aws_ecs_service" "kafka_producer_service" {
#   name            = "kafka-producer-service-${var.env}"
#   cluster         = data.aws_ecs_cluster.cluster.cluster_name
#   desired_count   = "1"
#   launch_type     = local.launch_type
#   task_definition = aws_ecs_task_definition.kafka_producer_task.arn
# }
