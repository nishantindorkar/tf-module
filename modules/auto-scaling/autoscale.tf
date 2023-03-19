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

locals {
  user_data_base64 = base64encode(var.user_data_script)
}
resource "aws_launch_template" "launch-template" {
  name = "scaling-instance-${var.appname}-${var.env}"
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  user_data   = local.user_data_base64
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
      volume_type = "gp2"
      delete_on_termination = false
    }
  }
}

resource "aws_autoscaling_group" "new-auto-group-public" {
  name = "auto-scale-public"
  launch_template {
    id = aws_launch_template.launch-template.id
    version = "$Latest"
  }
  min_size = 1
  max_size = 2
  desired_capacity = 2
  health_check_type = "EC2"
  vpc_zone_identifier = var.vpc_public
  termination_policies = ["OldestInstance"]
  
  tag {
    key = "Name"
    value = "${var.appname}-${var.env}-public-server"
    propagate_at_launch = true
  }
  
  metrics_granularity = "1Minute"
}

resource "aws_autoscaling_group" "new-auto-group-private" {
  name = "auto-scale-private"
  launch_template {
    id = aws_launch_template.launch-template.id
    version = "$Latest"
  }
  min_size = 2
  max_size = 4
  desired_capacity = 3
  health_check_type = "EC2"
  vpc_zone_identifier = var.vpc_zone_identifier
  termination_policies = ["OldestInstance"]
  
  tag {
    key = "Name"
    value = "${var.appname}-${var.env}-private-server"
    propagate_at_launch = true
  }
  
  metrics_granularity = "1Minute"
}

resource "aws_autoscaling_policy" "cpu-utilization-scaling-policy" {
  name                   = "cpu-utilization-scaling-policy-private"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }

  autoscaling_group_name = aws_autoscaling_group.new-auto-group-private.name
}

#################################
# with launch configuration
#################################

# resource "aws_launch_configuration" "launch-conf" {
#   name                 = "scaling-instance-${var.appname}-${var.env}"
#   image_id             = data.aws_ami.ubuntu.id
#   instance_type        = var.instance_type
#   key_name             = var.key_name
#   security_groups      = [var.security_group_id]
#   user_data            = <<EOF
# #!/bin/bash
# sudo apt update -y
# sudo apt install nginx -y
# wget https://www.free-css.com/assets/files/free-css-templates/download/page288/frica.zip
# sudo apt install unzip -y
# unzip frica.zip
# sudo rm -rf /var/www/html/*
# sudo mv html/* /var/www/html/
# sudo systemctl start nginx
# sudo systemctl enable nginx
# EOF
# }

# resource "aws_autoscaling_group" "new-auto-group" {
#   name                 = "auto-scale"
#   launch_configuration = aws_launch_configuration.launch-conf.name 
#   min_size             = 2
#   max_size             = 4
#   desired_capacity     = 3
#   health_check_type    = "EC2"
#   vpc_zone_identifier = var.vpc_public
#   #vpc_zone_identifier  = var.vpc_zone_identifier 
#   #target_group_arns    = var.aws_lb_target_group_arns
#   # lifecycle {
#   #   create_before_destroy = true
#   #   ignore_changes = [tag.Name]
#   # }
#   tag {
#     key                 = "Name"
#     value               = "dev-server"
#     propagate_at_launch = true
#   }
#   # tag {
#   #   key                 = "Name"
#   #   value               = "${var.appname}-${var.env}-server-${aws_autoscaling_group.new-auto-group.name}-${count.index + 1}"
#   #   propagate_at_launch = true
#   # }
# }
