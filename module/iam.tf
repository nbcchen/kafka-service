resource "aws_iam_role" "ecs_execution_role" {
  name               = "kafka-execution-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
  managed_policy_arns = [
    data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn,
    data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
  ]
}

# resource "aws_iam_role" "apprunner_execution_role" {
#   name_prefix = "kafka-${var.env}"
#   assume_role_policy = data.aws_iam_policy_document.apprunner_assume_role_policy.json 
#   managed_policy_arns = [  
#     data.aws_iam_policy.AWSAppRunnerServicePolicyForECRAccess.arn
#    ]
# }

resource "aws_iam_role_policy" "inline" {
  name_prefix = "kafka-${var.env}"
  policy      = data.aws_iam_policy_document.ecs_execution_inline_policy.json
  role        = aws_iam_role.ecs_execution_role.name
}
