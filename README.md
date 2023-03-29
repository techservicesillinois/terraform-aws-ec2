[![Terraform actions status](https://github.com/techservicesillinois/terraform-aws-ec2/workflows/terraform/badge.svg)](https://github.com/techservicesillinois/terraform-aws-ec2/actions)

# ec2

Provides an Elastic Computing Cloud (EC2) virtual server instance,
and optional Route 53 aliases.
This module only supports single-instance servers.

For more information, see the documentation on the Terraform
[aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) resource.

Example usage (simple case)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name        = "example"
  subnet_type = "public"
  vpc         = "vpc_name"
}

```
Example usage (with resized root volume and storage type)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name        = "example"
  subnet_type = "public"
  vpc         = "vpc_name"
  
  # Resize root volume to 16 gb and use gp3 storage.
  root_block_device = {
    volume_size = 16
    volume_type = "gp3"
  }
}
```

Example usage (alias block with Elastic IP assignment)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  alias = [
    {
    hostname = "example"
    domain   = "mydomain.example.com"
    }
  ]

  eip = {
    name     = "existing_eip_name"
    create   = false
  }

  name        = "example"
  subnet_type = "public"
  vpc         = "vpc_name"
}
```

**NOTE:** If you stop and start the EC2 instance from the console, command line interface, or API, the instance's IP address will change, but the alias record will not change. **This behavior causes the Route53 record to point to an IP address no longer associated with the EC2 instance.**

Avoid this by specifying an `eip` block, which attaches an Elastic IP address
that persists until destroyed. This Elastic IP address can be created at the time the EC2 instance is created. Alternatively, to have an 
Elastic IP address which persists unchanged even after the EC2 instance is 
torn down and rebuilt, create it in advance and look it up by name.

Example usage (with EBS volume)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name        = "example"
  subnet_type = "public"
  vpc         = "vpc_name"

  # Mount block storage device at /scratch.
  ebs_volume = {
    device_name = "/dev/xvdf"
    mount_point = "/scratch"
    volume_id   = "vol-cab005eb1ab"
  }
}
```

Example usage (with EFS file system)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name        = "example"
  subnet_type = "public"
  vpc         = "vpc_name"
 
  # Mount EFS file system at /mnt.
  efs_file_system = {
    file_system_id = "fs-deadb33f"
    mount_point    = "/mnt"
    source_path    = "/"
  }
}
```

Argument Reference
-----------------

The following arguments are supported:

* `name` - (Required) Name to assign to EC2 instance.

* `vpc` - (Required) The name of the virtual private cloud to be
associated with the instance.

* `alias` – (Optional) An [alias](#alias) block used to define a Route 53
"A" record that points to the EC2 instance(s).

* `ami_name_filter` - (Optional) List of image names to filter for
candidate AMIs.

* `ami_virtualization_type_filter` - (Optional) List of virtualization
types to filter for candidate AMIs.

* `ami_image_owner` - (Optional) List of Owner IDs to filter for
candidate AMIs.

* `associate_public_ip_address` - (Optional) Boolean specifying whether
public IP address is to be assigned. Default: true

* `cidr_blocks` - (Optional) List of CIDR blocks to have inbound SSH access
to the EC2 instance.

* `ebs_volume` – (Optional) An [ebs\_volume](#ebs_volume) block used to define the EBS volume to be attached to the EC2 instance(s).

* `efs_file_system` – (Optional) An [efs\_file\_system](#efs_file_system) block used to define the EFS file system to be attached to the EC2 instance(s).

* `eip` – (Optional) An [eip](#eip) block used to create or look up an Elastic IP to attach to the EC2 instance. To omit the Elastic IP entirely, do not specify an `eip` block.

* `instance_type` - (Optional) EC2 instance type. Default: t2.nano.

* `key_name` - (Optional) SSH key (if any) to assign to EC2 instance.

* `ports` - (Optional) Ports to be opened on the EC2 instance.

* `root_block_device` – (Optional) A [root_block_device](#root_block_device) block used to define characteristics of the root volume.

* `security_groups` - (Optional) List of security group names.

* `subnet_type` - (Required) Subnet type (e.g., 'campus', 'private', 'public') for resource placement.

* `tags` - (Optional) A mapping of tags to assign where supported.

* `template_file` - (Optional) User data template file.

* `private_ip` - (Optional) Private IP address to associate with the instance in a VPC.

`alias`
-------

An `alias` block supports the following keys:

* `domain` - (Required) The name of the Route 53 zone in which the record
is to be created.

* `hostname` – (Optional) The name of the host to be created in the
specified Route 53 zone. Default: the EC2 instance name (i.e., what
appears in the `name` attribute).

* `private_zone` – (Optional) Specify if the alias is to reside in a 
private zone inside the virtual private cloud (VPC). Default: false.

* `ttl` - (Optional) Time in seconds for DNS lookup to be cached. Default: 60.

* `use_private_ip` (Optional) Route53 record should use private rather than public IP address. Default: false.

Note that if the `hostname` is omitted, it will default to the `name`
specified for the EC2 instance. This default will not work unless each
`domain` specified is different, since multiple records with the same
name can not be added in the same Route53 zone.

`ebs_volume`
-------

An `ebs_volume` block supports the following keys:

* `device_name` - (Required) The device file name to which the EBS volume will be attached on the virtual host. The value is passed to the `user_data` template as `ebs_device_name`.

* `mount_point` – (Required) The path at which the EBS volume is to be mounted on the virtual host. The value is passed to the `user_data` template as `ebs_mount_point`.

* `volume_id` - (Required) The EBS volume ID. The value is *not* passed to the `user_data` template, because the volume attachment takes place before the `user_data` file is run, thereby rendering it useless after the virtual server is booted.

`efs_file_system`
-------

An `efs_file_system` block supports the following keys:

* `file_system_id` - (Required) The EFS file system ID. The derived file system name is passed to the `user_data` template as `efs_file_system_name`.

* `mount_point` – (Required) The path at which the EFS file system is to be mounted on the virtual host.  The value is passed to the `user_data` template as `efs_mount_point`.

* `source_path` - (Required) The path relative to the EFS file system root to be mounted on the virtual host. The value is passed to the `user_data` template as `efs_source_path`.

`eip`
-------

An `eip` block supports the following keys:

* `name` - (Optional) The name of the Elastic IP address to attach to this EC2 instance. This may be the name of an existing Elastic IP already created in a prior step, 
or a name to give to a new Elastic IP address to be created at the time the 
EC2 instance is created. Default is the name of the EC2 instance (given in 
the `name` argument above).

* `create` - (Required) Set to true if the Elastic IP is to be created for the
EC2 instance. Set to false if the Elastic IP already exists and is to be looked up.

`root_block_device`
-------------------

* `delete_on_termination`- (Optional) Whether the volume should be destroyed on instance termination. Defaults to true.

* `encrypted` - (Optional) Whether to enable volume encryption. Defaults to false.

* `iops` - (Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3.

* `kms_key_id` - (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume.

* `throughput` - (Optional) Throughput to provision for a volume in mebibytes per second (MiB/s). This is only valid for volume_type of gp3.

* `volume_size` - (Optional) Size of the volume in gibibytes (GiB).

* `volume_type` - (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp2.

Template variables
-------
The following variables are passed to the `user_data` template, and are
therefore available to the process by which the virtual host is provisioned.

* `ebs_device_name`
* `ebs_mount_point`
* `efs_file_system_name`
* `efs_mount_point`
* `efs_source_path`
* `hostname`

For details about the data populated into the `ebs_` and `efs_` variables,
please see the descriptions above for the [ebs\_volume](#ebs_volume) and [efs\_file\_system](#efs_file_system) blocks.

The `hostname` contains a fully-qualified domain name computed from the
first entry in the `alias` block, if any is defined.

Attributes Reference
--------------------

The following attributes are exported:

* `alias` – A list of fully qualified domain names (if any) for each alias created for the instance.

* `availability_zone` – The AWS availability zone to which the instance is assigned.

* `private_dns` - The private DNS name assigned to the instance.

* `private_ip` - The private IP address assigned to the instance

* `public_dns` - The public DNS name assigned to the instance, if any.

* `public_ip` - The public IP address assigned to the instance, if any.
