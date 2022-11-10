data "aws_route53_zone" "selected" {
  count = length(var.alias)

  name         = var.alias[count.index].domain
  vpc_id       = lookup(var.alias[count.index], "private_zone", false) ? local.vpc_id : null
  private_zone = lookup(var.alias[count.index], "private_zone", false)
}

resource "aws_route53_record" "default" {
  count = length(var.alias)

  zone_id = element(data.aws_route53_zone.selected.*.zone_id, count.index)
  name    = lookup(var.alias[count.index], "hostname", var.name)
  type    = "A"
  ttl     = lookup(var.alias[count.index], "ttl", 60)
  records = [(lookup(var.alias[count.index], "private_zone", false) || lookup(var.alias[count.index], "use_private_ip", false)) ? local.private_ip : local.public_ip]
}
