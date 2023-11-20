locals {
  lambda_names = keys(var.lambda_functions)
}


resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_gateway_name
}


resource "aws_api_gateway_resource" "proxy" {
  for_each = var.lambda_functions
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
  path_part   = each.value.path
}


# resource "aws_api_gateway_method" "proxy_root" {
#   rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
#   resource_id   = "${aws_api_gateway_rest_api.api_gateway.root_resource_id}"
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_root" {
#   for_each = var.lambda_functions
#   rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
#   resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
#   http_method = "${aws_api_gateway_method.proxy_root.http_method}"

#   integration_http_method = each.value.method
#   type                    = "AWS_PROXY"
#   uri                     = each.value.arn
# }

resource "aws_api_gateway_method" "proxy" {
  for_each = var.lambda_functions
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id   = "${aws_api_gateway_resource.proxy["${each.key}"].id}"
  http_method   = "${each.value.method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  for_each = var.lambda_functions
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  resource_id = "${aws_api_gateway_method.proxy["${each.key}"].resource_id}"
  http_method = "${aws_api_gateway_method.proxy["${each.key}"].http_method}"

  # integration_http_method = "${aws_api_gateway_method.proxy["${each.key}"].http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.arn
}


resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = var.stage_name
  xray_tracing_enabled = var.xray_tracing_enabled
}

resource "aws_api_gateway_method_settings" "api_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway.id}"
  stage_name  = "${aws_api_gateway_stage.api_stage.stage_name}"
  method_path = "*/*"
  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }
}

resource "aws_lambda_permission" "apigw" {
  for_each = toset(local.lambda_names)

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"

 
  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}