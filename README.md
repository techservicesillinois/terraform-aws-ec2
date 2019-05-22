[![Build Status](https://drone.techservices.illinois.edu/api/badges/techservicesillinois/terraform-aws-ec2/status.svg)](https://drone.techservices.illinois.edu/techservicesillinois/terraform-aws-ec2)

# ec2

Provides an Elastic Computing Cloud (EC2) virtual server instance,
and optional Route 53 aliases.
This module only supports single-instance servers on public subnets.

Example Usage
-----------------

```hcl
module "instance" {
  source = "git@github.com:techservicesillinois/terraform-aws-ec2"

  name = "example"
  tier = "public"
  vpc  = "vpc_name"
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

* `efs_file_system` - (Optional) Name of EFS volume to be rendered in
template. Default: empty string.

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

An `alias` block supports the following:

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

Attributes Reference
--------------------

The following attributes are exported:

* `fqdn_alias` – A list of fully qualified domain names (if any) for each alias created for the EC2 volume

* `fqdn_efs` – The fully qualified domain name of the EFS volume, if any.

* `public_dns` - The public DNS name assigned to the instance, if any.

* `public_ip` - The public IP address assigned to the instance, if any.

* `private_dns` - The private DNS name assigned to the instance.

* `private_ip` - The private IP address assigned to the instance
