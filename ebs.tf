locals {
  ebs_device_name = "${length(var.ebs_volume) > 0 ? lookup(var.ebs_volume, "device_name", "") : ""}"
  ebs_mount_point = "${length(var.ebs_volume) > 0 ? lookup(var.ebs_volume, "mount_point", "") : ""}"
}

resource "aws_volume_attachment" "default" {
  count        = "${length(var.ebs_volume) > 0 ? 1 : 0}"
  skip_destroy = true
  device_name  = "${lookup(var.ebs_volume, "device_name")}"
  volume_id    = "${lookup(var.ebs_volume, "volume_id")}"
  instance_id  = "${aws_instance.default.id}"
}
