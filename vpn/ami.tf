locals {
  openvpn_name  = "OpenVPN Access Server"
  openvpn_owner = "679593333241"
}


data "aws_ami" "latest_openvpn_ami" {
  owners      = ["${local.openvpn_owner}"]
  most_recent = true

  filter {
    name   = "name"
    values = ["${local.openvpn_name}*"]
  }
}
