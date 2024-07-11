resource "aws_iam_role" "ecs_execution_role" {
  name               = "kafka-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  inline_policy {
    policy = data.aws_iam_policy_document.ecs_execution_inline_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
