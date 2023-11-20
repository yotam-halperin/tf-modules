
output "function_name" {
  description = "Name of the Lambda function."
  value = aws_lambda_function.lambda_function.function_name
}

output function_arn {
  value = aws_lambda_function.lambda_function.arn
}

output "function_invoke_arn" {
  description = "arn of the Lambda function."
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "function_role_arn" {
  description = "arn of the lambda execution role"
  value = var.role_arn == "" ? aws_iam_role.lambda_exec[0].arn : var.role_arn
}