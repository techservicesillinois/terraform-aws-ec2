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
  default     = ""
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

variable "eip_create" {
  description = "Create elastic IP address for instance"
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.nano"
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

variable "tags" {
  description = "Mapping of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "tier" {
  description = "Subnet tier tag (e.g., public, private, nat) to determine subnets"
  default     = "public"
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
