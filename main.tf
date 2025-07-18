resource "aws_iam_instance_profile" "default" {
  for_each = toset(var.iam_instance_profile != null ? [var.iam_instance_profile] : [])

  name = each.key
  role = each.key
  tags = local.tags
}

locals {
  iam_instance_profile_name = try(aws_iam_instance_profile.default[var.iam_instance_profile].name, null)
}

resource "aws_instance" "default" {
  ami                         = data.aws_ami.selected.id
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = local.availability_zone
  iam_instance_profile        = local.iam_instance_profile_name
  instance_type               = var.instance_type
  key_name                    = var.key_name
  private_ip                  = var.private_ip
  subnet_id                   = local.subnet_id
  tags                        = local.tags
  user_data                   = templatefile(var.template_file, local.template_vars)

  vpc_security_group_ids = concat(
    [aws_security_group.default.id],
    flatten(data.aws_security_groups.selected.*.ids),
  )

  dynamic "root_block_device" {
    for_each = [var.root_block_device]
    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      iops                  = root_block_device.value.iops
      kms_key_id            = root_block_device.value.kms_key_id
      tags                  = merge(local.tags, { Name = format("%s:%s", var.name, "root") })
      throughput            = root_block_device.value.throughput
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
    }
  }

  # Suppress destruction and re-creation of resource when new AMIs
  # are released.
  lifecycle {
    ignore_changes = [ami]
  }
}

# Add tags to elastic network interface.

resource "aws_ec2_tag" "default" {
  resource_id = aws_instance.default.primary_network_interface_id

  for_each = local.tags
  key      = each.key
  value    = each.value
}
