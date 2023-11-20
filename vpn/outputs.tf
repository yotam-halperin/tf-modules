# output "openvpn_instance_dns" {
#   value = "https://${aws_route53_record.openvpn.name}:943/admin"
# }

output "openvpn_admin_pass_ASM" {
  value = aws_secretsmanager_secret.pass-asm.name
}
output "openvpn_private_key_secret_name" {
  value = aws_secretsmanager_secret.openvpn_instance_ssh_private_key.name
}
output "pass" {
  value     = random_password.admin_password.result
  sensitive = true
}
# output "openvpn_lb_dns" {
#   value = "https://${aws_route53_record.elb.name}/admin"
# }
output "vpn_security_group_id" {
  value     = aws_security_group.openvpn.id
}
output "vpn_elb_security_group_id" {
  value     = aws_security_group.openvpn_elb.id
}

output "admin_password_secret_arn" {
  value = aws_secretsmanager_secret.pass-asm.arn
  sensitive = true
}


