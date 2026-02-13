variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "EC2 instance type (t3.large recommended for SQL Server)"
  type        = string
  default     = "t3.large"
}

variable "allowed_ip" {
  description = "Your public IP in CIDR notation (e.g. 86.1.2.3/32). All ports are restricted to this IP."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ip, 0))
    error_message = "allowed_ip must be a valid CIDR block (e.g. 86.1.2.3/32)."
  }
}

variable "repo_url" {
  description = "Git repository URL to clone onto the instance"
  type        = string
  default     = "https://github.com/engsnayl/tm-lending-cdc-prototype.git"
}

variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}
