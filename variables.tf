# Required variables.
variable "name" {
  description = "Name to be assigned to EC2 instance"
}

variable "vpc" {
  description = "VPC in which EC2 instance is to be placed"
}

# Optional variables.

variable "alias" {
  description = "Route 53 alias block"
  type        = list(map(string))
  default     = []
}

variable "availability_zone" {
  description = "Availability zone for instance"
  default     = null
}

variable "ami_name_filter" {
  description = "List of image names to filter for candidate AMIs"
  type        = list(string)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
}

variable "ami_virtualization_type_filter" {
  description = "List of virtualization types to filter for candidate AMIs"
  type        = list(string)
  default     = ["hvm"]
}

# See https://aws.amazon.com/marketplace/seller-profile?id=565feec9-3d43-413e-9760-c651546613f2.
# The account ID shown belongs to https://www.canonical.com/, the Ubuntu folks.

variable "ami_image_owner" {
  description = "List of Owner IDs to filter for candidate AMIs"
  type        = list(string)
  default     = ["099720109477"]
}

variable "associate_public_ip_address" {
  description = "Boolean specifying whether public IP address is to be assigned"
  default     = true
}

variable "cidr_blocks" {
  description = "List CIDR blocks to have inbound SSH access to the EC2 instance"
  type        = list(string)
  default     = []
}

variable "ebs_volume" {
  description = "Map identifying EBS mount (Required keys: device_name, mount_point,and volume_id)"
  type        = map(string)
  default     = {}
}

variable "efs_file_system" {
  description = "Map identifying EFS mount (Required keys: file_system_id, mount_point and source_path)"
  type        = map(string)
  default     = {}
}

variable "eip" {
  description = "Create elastic IP address for instance"
  type        = map(any)
  default     = {}
}

variable "iam_instance_profile" {
  description = "IAM instance profile for this EC2 instance"
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "key_name" {
  description = "SSH key (if any) to assign to EC2 instance"
  default     = ""
}

variable "ports" {
  description = "Ports to be opened on the EC2 instance"
  type        = list(number)
  default     = []
}

variable "root_block_device" {
  description = "Definition for instance's root block device"
  type = object({
    delete_on_termination = optional(bool)
    encrypted             = optional(bool)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    throughput            = optional(number)
    volume_size           = optional(number)
    volume_type           = optional(string)
  })
  default = {
  }
}

variable "subnet_type" {
  description = "Subnet type (e.g., 'campus', 'private', 'public') for resource placement"
}

variable "tags" {
  description = "Mapping of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = "List of security group names (ID does not work!)"
  type        = list(string)
  default     = []
}

variable "template_file" {
  description = "User data template file"
  default     = "/dev/null"
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = null
}
