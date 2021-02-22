locals {
  # if eip map not defined at all, want_eip is false.

  # want EIP on the box at the end of this entire process?
  want_eip = lookup(var.eip, "create", null) != null

  # lookup an existing EIP, or create a new one?
  eip_create = lookup(var.eip, "create", false)

  # get name of EIP from the eip map, or default to name of the EC2 instance
  eip_name = lookup(var.eip, "name", null) != null ? lookup(var.eip, "name") : var.name

  private_ip = local.want_eip ? element(concat(aws_eip.default.*.private_ip, data.aws_eip.selected.*.private_ip, [""]), 0) : aws_instance.default.private_ip

  private_dns = local.want_eip ? element(concat(aws_eip.default.*.private_dns, data.aws_eip.selected.*.private_dns, [""]), 0) : aws_instance.default.private_dns

  public_ip = local.want_eip ? element(concat(aws_eip.default.*.public_ip, data.aws_eip.selected.*.public_ip, [""]), 0) : aws_instance.default.public_ip

  public_dns = local.want_eip ? element(concat(aws_eip.default.*.public_dns, data.aws_eip.selected.*.public_dns, [""]), 0) : aws_instance.default.public_dns
}

# lookup the existing EIP if that's what we're doing
data "aws_eip" "selected" {
  count = local.want_eip && (! local.eip_create) ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [local.eip_name]
  }
}

# create a new EIP in here if we want EIP, but don't have existing
resource "aws_eip" "default" {
  count = local.want_eip && local.eip_create ? 1 : 0

  tags = merge(var.tags, { "Name" = local.eip_name })
}

# Attach the EIP (whether created or looked up) to the EC2 instance
resource "aws_eip_association" "eip_assoc" {
  count = local.want_eip ? 1 : 0

  instance_id   = aws_instance.default.id
  allocation_id = local.eip_create ? aws_eip.default[0].id : data.aws_eip.selected[0].id
}
