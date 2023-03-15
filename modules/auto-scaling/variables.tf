variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_group_id" {
  description = "ID of the security group for the EC2 instances"
  type = string
}

variable "appname" {
  type    = string
}

variable "env" {
  type    = string
}

variable "vpc_zone_identifier" {
  type = list(string)
}

# variable "aws_lb_target_group_arns" {
#   type = list(string)  
# }