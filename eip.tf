resource "aws_eip" "default" {
  count    = "${var.eip_create ? 1 : 0}"
  instance = "${aws_instance.default.id}"
  vpc      = true
  tags     = "${merge(map("Name", var.name), var.tags)}"
}
