resource "aws_cloudwatch_event_rule" "lambda_event_rule" {
  count = var.create_eventbridge_trigger  ? 1 : 0  
  name = "${var.function_name}-event-rule"
  description = "event rule to trigger lambda ${var.function_name}"
  schedule_expression = "rate(${var.eventbridge_trigger_rate})"
}

resource "aws_cloudwatch_event_target" "lambda_event_rule_target" {
  count = var.create_eventbridge_trigger  ? 1 : 0  
  arn = aws_lambda_function.lambda_function.arn
  rule = aws_cloudwatch_event_rule.lambda_event_rule[count.index].name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  count = var.create_eventbridge_trigger  ? 1 : 0  
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_event_rule[count.index].arn
}