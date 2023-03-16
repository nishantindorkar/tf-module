variable "internal" {
  type = string
}

variable "type" {
  type = string
}

variable "appname" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "autoscaling_group_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "autoscaling_group_id" {
  type    = list(string)
  default = []
}

variable "security_group_id" {
  type = string  
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
}

variable "account_id" {
  description = "ID of the AWS account"
}

variable "user_id" {
  description = "ID of the IAM user"
}

variable "vpc_public" {
  type = list(string)
}