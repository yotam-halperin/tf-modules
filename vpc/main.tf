# VPC

resource "aws_vpc" "vpc" {
  cidr_block                     = var.cidr

  instance_tenancy               = var.instance_tenancy
  enable_dns_hostnames           = var.enable_dns_hostnames
  enable_dns_support             = var.enable_dns_support

  tags = merge({
    "Name" = "${var.environment_name}.${var.vpc_name}.vpc",
    "Environment" = "${var.environment_name}"
  },
  var.tags,
  var.vpc_tags)
}

# Public subnet

resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  // Mapping public IPs to public subnets, as currently in the existing resources
  map_public_ip_on_launch         = element(var.map_public_ip_on_launch, count.index)

  tags = merge({
    "Name" = "${var.environment_name}.${var.public_subnet_names[count.index]}.subnet",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.public_subnet_tags
  )
}

# Private subnet

resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch         = false


  tags = merge({
    "Name" = "${var.environment_name}.${var.private_subnet_names[count.index]}.subnet",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.private_subnet_tags
  )
}

################################################################################
# Optional default Security Group
################################################################################
resource "aws_default_security_group" "default_sg" {
  count = var.create_default_security_group ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge({
    "Name" = "${var.environment_name}.${var.default_security_group_name}.sg",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.default_security_group_tags
  )
}

################################################################################
# Optional DHCP Options Set
################################################################################

resource "aws_vpc_dhcp_options" "dhcp" {
  count = var.create_dhcp ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type


  tags = merge({
    "Name" = "${var.environment_name}.${var.dhcp_name}.dhcp",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.dhcp_options_tags
  )
}

resource "aws_vpc_dhcp_options_association" "dhcp_association" {
  count = var.create_dhcp ? 1 : 0

  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp[0].id
}

################################################################################
# Optional Internet Gateway
################################################################################

resource "aws_internet_gateway" "igw" {
  count = var.create_default_route_table && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.environment_name}.${var.igw_name}.igw",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.igw_tags,
  )  
}

################################################################################
# Optional Default route table
################################################################################
resource "aws_default_route_table" "rt" {
  count = var.create_default_route_table ? 1 : 0

  default_route_table_id = aws_vpc.vpc.default_route_table_id

  dynamic "route" {
    for_each = var.default_route_table_routes
    content {
      # One of the following destinations must be provided
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = merge({
    "Name" = "${var.environment_name}.${var.default_route_table_name}.rt",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.default_route_table_tags
  )
  lifecycle {
    ignore_changes = [route,]
  }
}

resource "aws_route_table_association" "rt_association" {
  count = (length(var.public_subnets) > 0 && var.create_default_route_table) ? length(var.public_subnets) : 0

  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_default_route_table.rt[0].id
}

################################################################################
# Optional Default Network ACL
################################################################################
resource "aws_default_network_acl" "acl" {
  count = var.create_default_network_acl ? 1 : 0

  default_network_acl_id = aws_vpc.vpc.default_network_acl_id

  subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)

  dynamic "ingress" {
    for_each = var.default_network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.default_network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = merge({
    "Name" = "${var.environment_name}.${var.default_network_acl_name}.acl",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.default_network_acl_tags
  )  
}

################################################################################
# NAT Gateway
################################################################################
resource "aws_nat_gateway" "ngw" {
  count = (var.create_nat_gateway || length(var.private_subnets) > 0) ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].allocation_id

  subnet_id = aws_subnet.public[0].id

  tags = merge({
    "Name" = "${var.environment_name}.${var.nat_gw_name}.ngw",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.nat_gateway_tags
  )

  depends_on = [aws_internet_gateway.igw]
}

################################################################################
# NAT EIP
################################################################################
resource "aws_eip" "nat_eip" {
  count = (var.create_nat_gateway || length(var.private_subnets) > 0) ? 1 : 0

  tags = merge({
    "Name" = "${var.environment_name}.${var.nat_eip_name}.eip",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.nat_eip_tags
  )
}

################################################################################
# Private route table
################################################################################
resource "aws_route_table" "private-rt" {
  count = length(var.private_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  dynamic "route" {
    for_each = var.private_route_table_routes
    content {
      # One of the following destinations must be provided
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      # instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[0].id
  }

  tags = merge({
    "Name" = "${var.environment_name}.${var.private_route_table_name}.rt",
    "Environment" = "${var.environment_name}"
    },
    var.tags,
    var.private_route_table_tags
  )
  lifecycle {
    ignore_changes = [route,]
  }
}

resource "aws_route_table_association" "private-rt_association" {
  count = (length(var.private_subnets) > 0) ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private-rt[0].id
}
