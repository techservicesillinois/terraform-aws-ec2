output "alias" {
  value = aws_route53_record.default.*.fqdn
}

output "availability_zone" {
  value = local.availability_zone
}

output "private_dns" {
  value = aws_instance.default.private_dns
}

output "private_ip" {
  value = aws_instance.default.private_ip
}

output "public_dns" {
  value = local.public_dns
}

output "public_ip" {
  value = local.public_ip
}
