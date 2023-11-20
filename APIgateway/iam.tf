resource "aws_api_gateway_account" "this" {
  count = var.create_apigateway_iam_account ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.cloudwatch[0].arn
}

data "aws_iam_policy_document" "assume_role" {
  count = var.create_apigateway_iam_account ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  count = var.create_apigateway_iam_account ? 1 : 0
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "cloudwatch" {
  count = var.create_apigateway_iam_account ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  count = var.create_apigateway_iam_account ? 1 : 0
  name   = "api_gateway_cloudwatch_global"
  role   = aws_iam_role.cloudwatch[0].id
  policy = data.aws_iam_policy_document.cloudwatch[0].json
}