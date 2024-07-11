resource "aws_cloudwatch_log_group" "kafka_log_group" {
  retention_in_days = 5
}
