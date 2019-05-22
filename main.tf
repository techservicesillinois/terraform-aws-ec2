resource "aws_instance" "default" {
  ami                         = "${data.aws_ami.default.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${concat(list(aws_security_group.default.id), flatten(data.aws_security_groups.selected.*.ids))}"]
  subnet_id                   = "${local.subnet_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.default.rendered}"
  tags                        = "${merge(map("Name", var.name), var.tags)}"
}
