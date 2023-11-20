
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.environment_name}-openvpn-elb"

  load_balancer_type = "application"

  vpc_id             = var.vpc_id
  subnets            = var.subnets_ids
  security_groups    = [aws_security_group.openvpn_elb.id]

  target_groups = [
    {
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = aws_instance.openvpn.id
          port = 443
          health_check = { 
            enabled             = true 
            interval            = 30 
            path                = "/?src=connect" 
            port                = 443
            healthy_threshold   = 2 
            unhealthy_threshold = 2
            timeout             = 5
            protocol            = "HTTPS" 
            matcher             = "200-399" 
          } 
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate.cert.arn
      target_group_index = 0
    }
  ]
}


resource "aws_security_group" "openvpn_elb" {
  name = "${var.environment_name}-vpn-security-group-elb"
  vpc_id      = var.vpc_id
  description = "Security group for elb"

  tags = merge(local.tags)
}
resource "aws_security_group_rule" "elb_igress_tcp_443" {
  security_group_id = aws_security_group.openvpn_elb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "elb_egress_all" {
  security_group_id = aws_security_group.openvpn_elb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
