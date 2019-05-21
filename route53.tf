data "aws_route53_zone" "selected" {
  count = "${length(var.alias)}"

  name = "${lookup(var.alias[count.index], "domain", "")}"

  # FIXME: This module has not been tested on non-public networks.
  # vpc_id       = "${local.vpc_id}"
  # private_zone = "${local.internal_lb}"
}

resource "aws_route53_record" "default" {
  count = "${length(var.alias)}"

  zone_id = "${element(data.aws_route53_zone.selected.*.zone_id, count.index)}"
  name    = "${lookup(var.alias[count.index], "hostname", var.name)}"
  type    = "A"
  ttl     = "${lookup(var.alias[count.index], "ttl", 60)}"
  records = ["${aws_instance.default.public_ip}"]
}
