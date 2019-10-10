output "alias" {
  value = "${aws_route53_record.default.*.fqdn}"
}

output "private_dns" {
  value = "${aws_instance.default.private_dns}"
}

output "private_ip" {
  value = "${aws_instance.default.private_ip}"
}

output "public_dns" {
  value = "${aws_instance.default.public_dns}"
}

output "public_ip" {
  value = "${local.public_ip}"
}
