terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }

    template = {
      source = "hashicorp/template"
    }
  }
}

locals {
  availability_zone = var.availability_zone == null ? random_shuffle.az[0].result[0] : var.availability_zone
  fqdn_efs          = element(concat(data.aws_efs_file_system.selected.*.dns_name, [""]), 0)
  subnet_id         = module.get-subnets.subnets_by_az[local.availability_zone][0]
  vpc_id            = module.get-subnets.vpc.id

  # Allow SSH port (22) by default.
  ports = sort(distinct(concat([22], var.ports)))
}

module "get-subnets" {
  source = "github.com/techservicesillinois/terraform-aws-util//modules/get-subnets?ref=v3.0.4"

  include_subnets_by_az = true
  subnet_type           = var.subnet_type
  vpc                   = var.vpc
}

# Choose a single random availability zone from map of AZs matching
# the specified subnet_type.

resource "random_shuffle" "az" {
  count = var.availability_zone == null ? 1 : 0

  input        = keys(module.get-subnets.subnets_by_az)
  result_count = 1
}

data "aws_security_groups" "selected" {
  count = length(var.security_groups)

  filter {
    name   = "group-name"
    values = var.security_groups
  }
}

data "aws_ami" "selected" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami_name_filter
  }

  filter {
    name   = "virtualization-type"
    values = var.ami_virtualization_type_filter
  }

  owners = var.ami_image_owner
}

data "aws_efs_file_system" "selected" {
  count          = length(var.efs_file_system) > 0 ? 1 : 0
  file_system_id = local.efs_file_system_id
}

locals {
  efs_file_system_id = lookup(var.efs_file_system, "file_system_id", "")
  efs_mount_point    = lookup(var.efs_file_system, "mount_point", "")
  efs_source_path    = lookup(var.efs_file_system, "source_path", "")
  hostname           = length(var.alias) > 0 ? format("%s.%s", lookup(var.alias[0], "hostname", var.name), var.alias[0].domain) : null
}

data "template_file" "selected" {
  template = file(var.template_file)

  # Pass hostname (fully-qualified domain name), and EBS and EFS variables
  # to template.
  vars = {
    ebs_device_name      = local.ebs_device_name
    ebs_mount_point      = local.ebs_mount_point
    efs_file_system_name = local.fqdn_efs
    efs_mount_point      = local.efs_mount_point
    efs_source_path      = local.efs_source_path
    hostname             = local.hostname
  }
}
