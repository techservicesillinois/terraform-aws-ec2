[![Build Status](https://drone.techservices.illinois.edu/api/badges/techservicesillinois/terraform-aws-ec2/status.svg)](https://drone.techservices.illinois.edu/techservicesillinois/terraform-aws-ec2)

# ec2

Provides an Elastic Computing Cloud (EC2) virtual server instance,
and optional Route 53 aliases.
This module only supports single-instance servers on public subnets.

Example usage (simple case)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name = "example"
  tier = "public"
  vpc  = "vpc_name"
}
```

Example usage (alias block with optional creation of elastic IP)
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

  eip_create = true
  name       = "example"
  tier       = "public"
  vpc        = "vpc_name"
}
```

Note that if you stop and start the EC2 instance, the IP address will
change, but the alias record will not change. This behavior causes
the Route53 record to be out of date.

Avoid this by using `eip_create`, which creates an elastic IP address
that persists until destroyed.

Example usage (with EBS volume)
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name = "example"
  tier = "public"
  vpc  = "vpc_name"

    # Mount block storage device at /scratch.
    ebs_volume {
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

  name = "example"
  tier = "public"
  vpc  = "vpc_name"
 
  # Mount EFS file system at /mnt.
  efs_file_system {
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

* `eip_create` – (Optional) A Boolean value specifying that an elastic IP address should be created and attached to the EC2 instance(s). Default is false.

* `instance_type` - (Optional) EC2 instance type. Default: t2.nano.

* `key_name` - (Optional) SSH key (if any) to assign to EC2 instance.

* `ports` - (Optional) Ports to be opened on the EC2 instance.

* `security_groups` - (Optional) List of security group names.

* `tags` - (Optional) A mapping of tags to assign to the resource.

* `template_file` - (Optional) User data template file.

* `tier` - (Optional) A subnet tier tag (e.g., public, private,
nat) to determine subnets to be associated with the load balancer.

`alias`
-------

An `alias` block supports the following keys:

* `domain` - (Required) The name of the Route 53 zone in which the record
is to be created.

* `hostname` – (Optional) The name of the host to be created in the
specified Route 53 zone. Default: the EC2 instance name (i.e., what
appears in the `name` attribute).

* `ttl` - (Optional) Time in seconds for DNS lookup to be cached. Default: 60.

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

Template variables
-------
The following variables are passed to the `user_data` template, and are therefore
available to the process by which the virtual host is provisioned.

* `ebs_device_name`
* `ebs_mount_point`
* `efs_file_system_name`
* `efs_mount_point`
* `efs_source_path`

For details about the data populated into these variables, please see the descriptions above for the [ebs\_volume](#ebs_volume) and [efs\_file\_system](#efs_file_system) blocks.

Attributes Reference
--------------------

The following attributes are exported:

* `fqdn_alias` – A list of fully qualified domain names (if any) for each alias created for the EC2 volume

* `fqdn_efs` – The fully qualified domain name of the EFS volume, if any.

* `public_dns` - The public DNS name assigned to the instance, if any.

* `public_ip` - The public IP address assigned to the instance, if any.

* `private_dns` - The private DNS name assigned to the instance.

* `private_ip` - The private IP address assigned to the instance
