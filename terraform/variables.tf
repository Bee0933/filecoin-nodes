variable "aws-region" {
  type        = string
  default     = "us-east-1"
  description = "server region"
}

variable "azs" {
  type = list(string)
}

variable "ssh-private-key-path" {
  type        = string
  default     = ""
  description = "Path to private key for ansible connection"
}

variable "ssh-user" {
  type        = string
  default     = "ubuntu"
  description = "description"
}

variable "key-name" {
  type        = string
  default     = "ansible-filecoin"
  description = "description"
}

variable "slack-webhook" {
  type        = string
  default     = ""
  description = "slack webhook url"
}
