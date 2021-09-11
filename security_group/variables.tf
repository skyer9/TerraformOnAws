variable "stack_name" {
  description = "The name to prefix onto resources."
  type        = string
  default     = "my"
}

variable "region" {
  description = "The AWS region to deploy into."
  type        = string
  default     = "ap-northeast-2"
}

variable "allowlist_ip" {
  description = "A list of IP address to grant access via the LBs."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
