resource "aws_security_group" "kafka_zookeeper_sg" {
  description = "security group for kafka zookeeper"
  vpc_id = var.vpc_id
  ingress {
    from_port = 2181
    to_port   = 2181
    protocol  = "tcp"
    cidr_blocks = [
      "172.16.0.0/12",
      "10.0.0.0/8",
      "192.168.0.0/16"
    ]
  }

  egress {
    description = "Outbound for Kafka zookeeper"
    from_port   = 0
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
