
variable "aws-cred-profile" {
  type        = string
  default     = ""
  description = "AWS Credentials Profile"
}

variable "aws-region" {
  type        = string
  default     = "us-east-1"
  description = "server region"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a"]  
}

# variable "ubuntu-ami" {
#   type        = string
#   default     = ""
#   description = "aws AMI for ubunto server"
# }


