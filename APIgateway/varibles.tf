variable "api_gateway_name" {
  type = string
}
variable "stage_name" {
  type = string
}
variable lambda_functions {
  type        = map(map(string))
  default     = {}
}
variable xray_tracing_enabled {
  type        = bool
  default     = false
  description = "choose if to enable X-RAY"
}
variable create_apigateway_iam_account {
  type        = bool
  default     = false
  description = "choose if to give permission from the api gateway service to access cloudwatch"
}
