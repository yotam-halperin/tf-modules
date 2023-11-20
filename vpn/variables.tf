variable "domain_name" {
  type        = string
  description = "environment primary domain name"
}
variable "enable_ssh" {
  description = "toggle to enable ssh"
  type        = bool
  default     = false
}
variable "subnets_ids" {
  description = "subnet id for the openvpn server"
  type        = list(string)
}
variable "vpc_id" {
  description = "vpc id for the openvpn server"
  type = string
}

variable "default_tags" {
  description = "default tags for any aws resources"
  type        = any
  default = {}

}
variable "environment_name" {
  type        = string
  description = "name of the environment dev/staging/prod/qa/etc..."
}

