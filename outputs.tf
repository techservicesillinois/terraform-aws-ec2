output "alias" {
  value = { for x in aws_route53_record.default : x.fqdn => x.records }
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
  value = (local.public_dns != "") ? local.public_dns : null
}

output "public_ip" {
  value = (local.public_ip != "") ? local.public_ip : null
}
