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

variable "vpc_public" {
  type = list(string)
}

variable "user_data_script" {
  default = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
wget https://www.free-css.com/assets/files/free-css-templates/download/page288/frica.zip
sudo apt install unzip -y
unzip frica.zip
sudo rm -rf /var/www/html/*
sudo mv html/* /var/www/html/
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
}

# variable "aws_lb_target_group_arns" {
#   type = list(string)  
# }