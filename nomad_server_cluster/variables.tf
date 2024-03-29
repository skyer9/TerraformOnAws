variable "stack_name" {
  description = "The name to prefix onto resources."
  type        = string
  default     = "my"
}

variable "owner_name" {
  description = "Your name so resources can be easily assigned."
  type        = string
  default     = "skyer9"
}

variable "owner_email" {
  description = "Your email so you can be contacted about resources."
  type        = string
  default     = "skyer9@gmail.com"
}

variable "region" {
  description = "The AWS region to deploy into."
  type        = string
  default     = "ap-northeast-2"
}

variable "availability_zones" {
  description = "The AWS region AZs to deploy into."
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "ami" {
  description = "The AMI to use, preferably built by the supplied Packer scripts."
  type        = string
  default     = "ami-0ea5eb4b05645aa8a"
}

variable "consul_server_instance_type" {
  description = "The EC2 instance type to launch for Consul servers."
  type        = string
  default     = "t3a.micro"
}

variable "server_instance_type" {
  description = "The EC2 instance type to launch for Nomad servers."
  type        = string
  default     = "t3a.micro"
}

variable "client_instance_type" {
  description = "The EC2 instance type to launch for Nomad clients."
  type        = string
  default     = "t3a.small"
}

variable "consul_server_count" {
  description = "The number of Consul servers to run."
  type        = number
  default     = 1
}

variable "server_count" {
  description = "The number of Nomad servers to run."
  type        = number
  default     = 1
}

variable "client_count" {
  description = "The number of Nomad clients to run."
  type        = number
  default     = 1
}

variable "root_block_device_size" {
  description = "The number of GB to assign as a block device on instances."
  type        = number
  default     = 8
}

variable "retry_join" {
  description = "The retry join configuration to use."
  type        = string
  default     = "provider=aws tag_key=ConsulAutoJoin tag_value=auto-join"
}

variable "allowlist_ip" {
  description = "A list of IP address to grant access via the LBs."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "access_key" {
  description = "AWS_ACCESS_KEY_ID"
  type        = string
  default     = "XXXXXXXXXXXXXXX"
}

variable "secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY"
  type        = string
  default     = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
