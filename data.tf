locals {
  fqdn_efs  = "${element(concat(data.aws_efs_file_system.selected.*.dns_name, list("")), 0)}"
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
  count = "${length(var.security_groups)}"

  filter {
    name   = "group-name"
    values = ["${var.security_groups}"]
  }
}

data "aws_ami" "selected" {
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

data "aws_efs_file_system" "selected" {
  file_system_id = "${local.efs_file_system_id}"
}

provider "template" {}

locals {
  ebs_device_name    = "${lookup(var.ebs_volume, "device_name")}"
  ebs_mount_point    = "${lookup(var.ebs_volume, "mount_point")}"
  ebs_volume_id      = "${lookup(var.ebs_volume, "volume_id")}"
  efs_file_system_id = "${lookup(var.efs_file_system, "file_system_id")}"
  efs_mount_point    = "${lookup(var.efs_file_system, "mount_point")}"
  efs_source_path    = "${lookup(var.efs_file_system, "source_path")}"
}

data "template_file" "selected" {
  template = "${file("${var.template_file}")}"

  vars = {
    ebs_device_name      = "${local.ebs_device_name}"
    ebs_mount_point      = "${local.ebs_mount_point}"
    efs_file_system_name = "${local.fqdn_efs}"
    efs_mount_point      = "${local.efs_mount_point}"
    efs_source_path      = "${local.efs_source_path}"
  }
}
