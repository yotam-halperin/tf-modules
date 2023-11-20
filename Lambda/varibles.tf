variable "runtime" {
  type = string
  default = "dotnet6"
}

variable "handler" {
  type = string
  default = "GhostServers::GhostServers.LambdaEntryPoint::HandlerAsync"
}

variable "s3_bucket_id" {
  type = string
  default = "ghostapptestcodedeveleap"

}
variable "s3_bucket_key" {
  type = string
 }

variable "function_name" {
   type = string
  default = ""
  
}

variable "sg_id" {
  type = string
  default = ""
}
variable "vpc_subnet_ids" {
  type = list(string)
  default = [ ]
}
 
variable "list_event_sources_arn" {
  type = list(string)
  default = []
}
variable "vpc_security_group_ids" {
    type = list(string)
    default = [ "" ]
  
}
variable timeout {
  type        = number
  default     = 30
  description = "function timeout"
}
variable memory_size {
  type        = number
  default     = 256
  description = "function memory size"
}



### EventBridge variables ###
variable create_eventbridge_trigger {
  type        = bool
  default     = false
  description = "do you want an eventbridge event to trigger the lambda function?"
}

variable eventbridge_trigger_rate {
  type        = string
  default     = "5 minutes"
  description = "when to trigger the lambda function"
}

### create lambda role ###
variable create_function_role {
  type        = map(list(string))
  default     = {}
}
variable role_arn {
  type        = string
  default     = ""
}

