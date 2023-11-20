resource "aws_iam_role" "lambda_exec" {
  count = var.role_arn == "" ? 1 : 0
  name = "RoleForLambda${var.function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}


#####


resource "aws_iam_role_policy_attachment" "lambda_policy" {
  for_each = toset(var.create_function_role["aws_managed_policies_arns"])
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = each.value
}


#####

resource "aws_iam_policy" "lambda_function_policy_dynamodb" {
  count = var.role_arn == "" && length(var.create_function_role["dynamodb_tables_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_dynamodb_policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable",
          "dynamodb:ConditionCheckItem"
        ],
        Effect   = "Allow",
        Resource = var.create_function_role["dynamodb_tables_arns"],
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "policy_dynamodb_attachment" {
  count = var.role_arn == "" && length(var.create_function_role["dynamodb_tables_arns"]) > 0 ? 1 : 0

  name = "${var.function_name}_lambda_function_dynamodb_policy_attachment"
  roles      = [aws_iam_role.lambda_exec[0].name]
  policy_arn = aws_iam_policy.lambda_function_policy_dynamodb[0].arn
}


#####


resource "aws_iam_policy" "aspnetore_function_policy_sqs" {
  count = var.role_arn == "" && length(var.create_function_role["sqs_queues_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_sqs_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:*"],
        Resource = var.create_function_role["sqs_queues_arns"],
      },
    ],
  })
}


resource "aws_iam_policy_attachment" "policy_sqs_attachment" {
  count = var.role_arn == "" && length(var.create_function_role["sqs_queues_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_sqs_policy_attachment"
  roles      = [aws_iam_role.lambda_exec[0].name]
  policy_arn = aws_iam_policy.aspnetore_function_policy_sqs[0].arn
}


#####


resource "aws_iam_policy" "aspnetcore_function_S3" {
  count = var.role_arn == "" && length(var.create_function_role["s3_buckets_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_s3_policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetLifecycleConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:DeleteObject",
        ],
        Resource = var.create_function_role["s3_buckets_arns"],
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "Policy_S3_attachment" {
  count = var.role_arn == "" && length(var.create_function_role["s3_buckets_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_s3_policy_attachment"
  roles      = [aws_iam_role.lambda_exec[0].name]
  policy_arn = aws_iam_policy.aspnetcore_function_S3[0].arn
}


#####


resource "aws_iam_policy" "aspnetore_function_policy_secrets" {
  count = var.role_arn == "" && length(var.create_function_role["secret_manager_secrets_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_secret_manager_policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Effect   = "Allow",
        Resource = var.create_function_role["secret_manager_secrets_arns"],
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "policy_secrets_attachment" {
  count = var.role_arn == "" && length(var.create_function_role["secret_manager_secrets_arns"]) > 0 ? 1 : 0
  name = "${var.function_name}_lambda_function_secret_manager_policy_attachment"
  roles      = [aws_iam_role.lambda_exec[0].name]
  policy_arn = aws_iam_policy.aspnetore_function_policy_secrets[0].arn
}

#### ALLOW ACCESS TO CLOUDWATCH LOGS ####

resource "aws_iam_policy" "lambda_function_logs_policy" {
  count = var.role_arn == "" ? 1 : 0 
  name = "${var.function_name}_lambda_function_coludwatch_logs_policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*:${local.loggroup_name}:*"
      }
    ],
  })
}

resource "aws_iam_policy_attachment" "policy_logs_attachment" {
  count = var.role_arn == "" ? 1 : 0
  name = "${var.function_name}_lambda_function_coludwatch_logs_policy_attachment"
  roles      = [aws_iam_role.lambda_exec[0].name]
  policy_arn = aws_iam_policy.lambda_function_logs_policy[0].arn
}
