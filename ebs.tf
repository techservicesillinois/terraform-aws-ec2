locals {
  ebs_device_name = length(var.ebs_volume) > 0 ? lookup(var.ebs_volume, "device_name", "") : ""
  ebs_mount_point = length(var.ebs_volume) > 0 ? lookup(var.ebs_volume, "mount_point", "") : ""
}

resource "aws_volume_attachment" "default" {
  count = length(var.ebs_volume) > 0 ? 1 : 0

  device_name  = var.ebs_volume["device_name"]
  instance_id  = aws_instance.default.id
  skip_destroy = true
  volume_id    = var.ebs_volume["volume_id"]
}
