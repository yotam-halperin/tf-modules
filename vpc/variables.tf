variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "environment_name" {
    description = "The environment in which we are creating the VPC."
    type      = string
}

variable "region_name" {
    description = "The region, or data-center in which we are creating the VPC."
    type      = string
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

################################################################################
# VPC
################################################################################
variable "vpc_name" {
  description = "Name to be used on the VPC."
  type        = string
  default = "my_vpc"
}

variable "cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type        = string
  description = "The tenancy of all instances launched into the VPC."
  default     = "default"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Whether to enable the automatic assignment of public hostnames to instances in the VPC."
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether to enable the resolution of public DNS hostnames to private IP addresses."
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

################################################################################
# Public Subnet
################################################################################
variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default = ["10.0.10.0/24","10.0.20.0/24"]
}

variable "public_subnet_names" {
  description = "Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated."
  type        = list(string)
  default = ["public-1","public-2"]
}

variable "map_public_ip_on_launch" {
  description = "(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
  type        = list(bool)
  default = [true, true]
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

################################################################################
# Private subnet
################################################################################
variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default = ["10.0.30.0/24","10.0.40.0/24"]
}

variable "private_subnet_names" {
  description = "Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated."
  type        = list(string)
  default = ["private-1","private-2"]
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

################################################################################
# Security Group
################################################################################
variable "create_default_security_group" {
  description = "Should be true to create default security group"
  type        = bool
  default     = false
}

variable "default_security_group_name" {
  description = "Name to be used on the default security group"
  type        = string
  default     = "default"
}

variable "default_security_group_ingress" {
  description = "List of maps of ingress rules to set on the default security group"
  type        = list(map(string))
  default     = [
    {    
        from_port   = 0
        to_port     = 0
        protocol    = "all"
        self        = true
        description = "Default ingress"
    },
    ]
}

variable "default_security_group_egress" {
  description = "List of maps of egress rules to set on the default security group"
  type        = list(map(string))
  default     = [
    {
        from_port   = 0
        to_port     = 0
        protocol    = "all"
        cidr_blocks = "0.0.0.0/0"
        description = "Default egress"
    },
  ]
}

variable "default_security_group_tags" {
  description = "Additional tags for the default security group"
  type        = map(string)
  default     = {}
}

################################################################################
# DHCP Options Set
################################################################################
variable "create_dhcp" {
  description = "Should be true to create DHCP options"
  type        = bool
  default     = false
}

variable "dhcp_name" {
  description = "Name to be used on the DHCP options"
  type        = string
  default     = "default"
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP option set (requires enable_dhcp_options set to true)"
  type        = map(string)
  default     = {}
}

################################################################################
# Internet Gateway
################################################################################
variable "igw_name" {
  description = "Name to be used on the Internet Gateway."
  type        = string
  default     = "default"
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

################################################################################
# Default route table
################################################################################
variable "create_default_route_table" {
  description = "Should be true to create default route table"
  type        = bool
  default     = false
}

variable "default_route_table_name" {
  description = "Name to be used on the default route table"
  type        = string
  default     = "default"
}

variable "default_route_table_routes" {
  description = "Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route"
  type        = list(map(string))
  default     = []
}

variable "default_route_table_tags" {
  description = "Additional tags for the default route table"
  type        = map(string)
  default     = {}
}

################################################################################
# Default Network ACL
################################################################################
variable "create_default_network_acl" {
  description = "Should be true to create Default Network ACL"
  type        = bool
  default     = false
}

variable "default_network_acl_name" {
  description = "Name to be used on the Default Network ACL"
  type        = string
  default     = "default"
}

variable "default_network_acl_ingress" {
  description = "List of maps of ingress rules to set on the Default Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "default_network_acl_egress" {
  description = "List of maps of egress rules to set on the Default Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "default_network_acl_tags" {
  description = "Additional tags for the Default Network ACL"
  type        = map(string)
  default     = {}
}


################################################################################
# NAT Gateway
################################################################################
variable "create_nat_gateway" {
  description = "Should be true if you want to create NAT Gateway"
  type        = bool
  default     = false
}

variable "nat_gw_name" {
  description = "Name to be used on the Default Network ACL"
  type        = string
  default     = "default"
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  type        = map(string)
  default     = {}
}

################################################################################
# NAT EIP
################################################################################
variable "nat_eip_name" {
  description = "Name to be used on the Default Network ACL"
  type        = string
  default     = "default"
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type        = map(string)
  default     = {}
}

################################################################################
# Private route table
################################################################################
variable "private_route_table_name" {
  description = "Name to be used on the private route table"
  type        = string
  default     = "private"
}

variable "private_route_table_routes" {
  description = "Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route"
  type        = list(map(string))
  default     = []
}

variable "private_route_table_tags" {
  description = "Additional tags for the default route table"
  type        = map(string)
  default     = {}
}
