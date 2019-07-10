resource "aws_volume_attachment" "default" {
  skip_destroy = true
  device_name  = "${local.ebs_device_name}"
  volume_id    = "${local.ebs_volume_id}"
  instance_id  = "${aws_instance.default.id}"
}
