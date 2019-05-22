resource "aws_security_group" "default" {
  description = "EC2 instance ${var.name} security group"
  name        = "${var.name}"
  vpc_id      = "${local.vpc_id}"
  tags        = "${merge(map("Name", var.name), var.tags)}"
}

resource "aws_security_group_rule" "in_tcp" {
  count       = "${length(local.ports)}"
  description = "Allow inbound TCP connections to EC2 instance ${var.name}"

  type        = "ingress"
  from_port   = "${element(local.ports, count.index)}"
  to_port     = "${element(local.ports, count.index)}"
  protocol    = "tcp"
  cidr_blocks = "${var.cidr_blocks}"

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "in_icmp" {
  description = "Allow inbound ICMP traffic for EC2 instance ${var.name}"

  type        = "ingress"
  from_port   = -1            # Allow any ICMP type number
  to_port     = -1            # Allow any ICMP code
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "out" {
  description = "Allow outbound connections for all protocols and all ports for EC2 instance ${var.name}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.default.id}"
}
