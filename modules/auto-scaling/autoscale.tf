data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_configuration" "launch-conf" {
  name                 = "scaling-instance-${var.appname}-${var.env}"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_groups      = [var.security_group_id]
  user_data            = <<EOF
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

resource "aws_autoscaling_group" "new-auto-group" {
  name                 = "auto-scale"
  launch_configuration = aws_launch_configuration.launch-conf.name 
  min_size             = 2
  max_size             = 4
  desired_capacity     = 3
  health_check_type    = "EC2"
  vpc_zone_identifier = var.vpc_public
  #vpc_zone_identifier  = var.vpc_zone_identifier 
  #target_group_arns    = var.aws_lb_target_group_arns
  # lifecycle {
  #   create_before_destroy = true
  #   ignore_changes = [tag.Name]
  # }
  tag {
    key                 = "Name"
    value               = "dev-server"
    propagate_at_launch = true
  }
  # tag {
  #   key                 = "Name"
  #   value               = "${var.appname}-${var.env}-server-${aws_autoscaling_group.new-auto-group.name}-${count.index + 1}"
  #   propagate_at_launch = true
  # }
}
