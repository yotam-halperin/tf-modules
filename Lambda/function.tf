locals {
  lambda_execution_role = var.role_arn == "" ? aws_iam_role.lambda_exec[0].arn : var.role_arn
  loggroup_name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
}


resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name

  s3_bucket = var.s3_bucket_id
  s3_key    = var.s3_bucket_key

  timeout = var.timeout
  memory_size = var.memory_size

  runtime = var.runtime
  handler = var.handler

  
  environment {
    variables = {
     
    }
  }

  role = local.lambda_execution_role
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name = "${local.loggroup_name}"
  retention_in_days = 30
}


resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  for_each = toset(var.list_event_sources_arn)
  event_source_arn =  "${each.value}"
  enabled          = true
  function_name    = aws_lambda_function.lambda_function.function_name
  batch_size       = 1

}

 
resource "aws_lambda_permission" "allows_sqs_to_trigger_lambda" {

  for_each = toset(var.list_event_sources_arn)

  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = "${each.value}"
}
