resource "aws_instance" "default" {
  ami                         = data.aws_ami.selected.id
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = local.availability_zone
  instance_type               = var.instance_type
  key_name                    = var.key_name
  private_ip                  = var.private_ip
  subnet_id                   = local.subnet_id
  tags                        = merge({ Name = var.name }, var.tags)
  user_data                   = data.template_file.selected.rendered

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
      tags                  = merge(var.tags, { Name = format("%s:%s", var.name, "root") })
      throughput            = root_block_device.value.throughput
      volume_size           = root_block_device.value.volume_size
      volume_type           = root_block_device.value.volume_type
    }
  }
}
