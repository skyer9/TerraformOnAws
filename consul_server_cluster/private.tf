variable "key_name" {
  description = "The EC2 key pair to use for EC2 instance SSH access."
  type        = string
  default     = "aws_key"                   # 내 키페어
}

variable "my_ip" {
  description = "A list of IP address to grant access via the LBs."
  type        = list(string)
  default     = ["112.218.XXX.XXX/32"]      # 내 아이피
}
