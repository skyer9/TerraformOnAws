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

# AWS ECR 접속용 KEY
variable "access_key" {
  description = "AWS_ACCESS_KEY_ID"
  type        = string
  default     = "XXXXXXXXXXXXXXX"
}

# AWS ECR 접속용 KEY
variable "secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY"
  type        = string
  default     = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}
