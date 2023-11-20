locals {
  name = "${var.environment_name}-openvpn"
  tags = {
    "Environment" = var.environment_name
    "Name "       = "${var.environment_name}-openvpn"
  }
}

resource "aws_security_group" "openvpn" {
  name = "${var.environment_name}.vpn.security-group"
  vpc_id      = var.vpc_id
  description = "Security group for VPN access server"

  tags = merge(local.tags)
}

resource "aws_security_group_rule" "ingress_tcp_943" {
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "igress_tcp_443" {
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = aws_security_group.openvpn_elb.id
}

resource "aws_security_group_rule" "ingress_udp_1194" {
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = aws_security_group.openvpn.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Toggle to enable/disable SSH
# SSH isn't required for OpenVPN to function
# Only required when initializing the Access Server and maintenance tasks
resource "aws_security_group_rule" "openvpn" {
  count             = var.enable_ssh ? 1 : 0
  description       = "Temporarily enables SSH (22) for accessing the OpenVPN server for initialization and maintenance tasks. Disable when done with task."
  security_group_id = aws_security_group.openvpn.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "random_password" "admin_password" {
  length           = 16
  special          = false
  lower            = true
  upper            = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}



resource "aws_instance" "openvpn" {
  ami                         = data.aws_ami.latest_openvpn_ami.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.openvpn.id]
  associate_public_ip_address = true
  subnet_id         = var.subnets_ids[0]
  key_name          = aws_key_pair.openvpn.key_name
  source_dest_check = false
  user_data         = <<-EOF
  #!/bin/bash
  sleep 1
  sudo /usr/local/openvpn_as/bin/ovpn-init --batch --ec2 --force && echo done
  sleep 5
  sudo /usr/local/openvpn_as/scripts/sacli --user openvpn --new_pass ${random_password.admin_password.result} SetLocalPassword
  sudo /usr/local/openvpn_as/scripts/sacli --key vpn.client.routing.reroute_dns --value true ConfigPut #use server dns 
  sudo /usr/local/openvpn_as/scripts/sacli start

  EOF
  tags              = merge(local.tags,{"Name"="${var.environment_name}-openvpn"})
}

resource "aws_eip" "openvpn" {
  instance = aws_instance.openvpn.id
  domain = "vpc"

  tags = merge(local.tags)
}

#open ssh

resource "tls_private_key" "openvpn" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "openvpn" {
  key_name   = "${var.environment_name}-openvpn"
  public_key = tls_private_key.openvpn.public_key_openssh
}

resource "aws_secretsmanager_secret" "openvpn_instance_ssh_private_key" {
  name                    = "${var.environment_name}/openvpn/instance-keypair/private-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "openvpn_instance_ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.openvpn_instance_ssh_private_key.id
  secret_string = tls_private_key.openvpn.private_key_pem
}

resource "aws_secretsmanager_secret" "pass-asm" {
  name                    = "${var.environment_name}/openvpn/admin-pass"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.pass-asm.id
  secret_string = random_password.admin_password.result
}

//DNS

data "aws_route53_zone" "primary" {
  name = var.domain_name
}


resource "aws_route53_record" "elb" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "elb-openvpn.${data.aws_route53_zone.primary.name}" //record name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
