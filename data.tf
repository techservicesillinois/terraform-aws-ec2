locals {
  fqdn      = "${element(concat(data.aws_efs_file_system.default.*.dns_name, list("")), 0)}"
  subnet_id = "${element(data.aws_subnet_ids.selected.ids, 0)}"
  vpc_id    = "${data.aws_vpc.selected.id}"

  # Allow SSH port (22) by default.
  ports = "${sort(distinct(concat(list("22"), var.ports)))}"
}

data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc}"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Tier = "${var.tier}"
  }
}

data "aws_security_groups" "selected" {
  count = "${length(var.security_groups) > 0 ? 1 : 0}"

  filter {
    name   = "group-name"
    values = ["${var.security_groups}"]
  }
}

data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name_filter}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.ami_virtualization_type_filter}"]
  }

  owners = ["${var.ami_image_owner}"]
}

data "aws_efs_file_system" "default" {
  count          = "${var.efs_file_system != "" ? 1 : 0}"
  file_system_id = "${var.efs_file_system}"
}

provider "template" {}

data "template_file" "default" {
  template = "${file("${var.template_file}")}"

  vars = {
    efs_filesystem_name = "${local.fqdn}"
  }
}
