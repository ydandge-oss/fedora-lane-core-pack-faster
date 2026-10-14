variable "aws_region" {
  type        = string
  description = "AWS region (Fedora Lane primary e-commerce style)"
  default     = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "fl-poc"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "ssh_cidr" {
  type        = string
  description = "Your public IP as x.x.x.x/32 — do not use 0.0.0.0/0 for long-lived labs"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Optional VPC ID; empty uses default VPC behavior for SG"
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Optional subnet; empty lets AWS choose default"
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "Pin a specific AMI; empty uses data source lookup"
}

variable "ami_owners" {
  type        = list(string)
  default     = ["309956199498"] # Red Hat
  description = "Override to 679593333241 (Marketplace) or your account as needed"
}

variable "ami_name_filter" {
  type        = string
  default     = "RHEL-9.*_HVM-*-x86_64-*-Hourly2-GP3"
  description = "Adjust if RHEL PAYG naming differs in your region; or use Rocky-9* with owners=["679593333241"] for practice"
}
