provider "aws" {
  profile = "Rick"
  region  = "us-east-1"
}

module "vpc" {
  source                          = "../../modules/vpc"
  cidr_blocks                     = "10.0.0.0/16"
  cidr_blocks_defualt             = "0.0.0.0/0"
  public_cidr_blocks              = ["10.0.1.0/24", "10.0.2.0/24","10.0.3.0/24"]
  private_cidr_blocks             = ["10.0.4.0/24", "10.0.5.0/24","10.0.6.0/24"]
  availability_zones              = ["us-east-1a", "us-east-1b","us-east-1c"]
  map_public_ip_on_launch         = true
  appname = "web"
  env = "development"
}

# module "loadbalancer" {
  
# }

# module "autoscaling" {
#   instance_count                  = 2
#   instance_type                   = "t2.micro"
#   key_name                        = "allPurposeVirginia"
#   ecs_associate_public_ip_address = true
# }