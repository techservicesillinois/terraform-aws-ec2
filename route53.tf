data "aws_route53_zone" "selected" {
  count = length(var.alias)

  name = lookup(var.alias[count.index], "domain", "")
}

locals {
  public_ip = var.eip_create ? element(concat(aws_eip.default.*.public_ip, [""]), 0) : aws_instance.default.public_ip
}

resource "aws_route53_record" "default" {
  count = length(var.alias)

  zone_id = element(data.aws_route53_zone.selected.*.zone_id, count.index)
  name    = lookup(var.alias[count.index], "hostname", var.name)
  type    = "A"
  ttl     = lookup(var.alias[count.index], "ttl", 60)
  records = [local.public_ip]
}
