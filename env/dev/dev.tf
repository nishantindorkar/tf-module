provider "aws" {
  profile = "Rick"
  region  = "us-east-1"
}

module "vpc" {
  source                  = "../../modules/vpc"
  cidr_blocks             = "10.0.0.0/16"
  cidr_blocks_defualt     = "0.0.0.0/0"
  public_cidr_blocks      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidr_blocks     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  map_public_ip_on_launch = true
  appname                 = "web"
  env                     = "development"
}

module "loadbalancer" {
  source   = "../../modules/load-balancer"
  internal = "false"
  type     = "application"
  tags = {
    Owner = "dev-one"
  }
  appname                = module.vpc.appname
  env                    = module.vpc.env
  security_group_id      = module.vpc.security_group_id
  subnets                = module.vpc.private_subnet_ids
  vpc_id                 = module.vpc.vpc_id
  autoscaling_group_name = module.autoscaling.autoscaling_group_name
  bucket_name = module.loadbalancer.bucket_name
  account_id = module.loadbalancer.account_id
  user_id = module.loadbalancer.user_id
  vpc_public = module.vpc.public_subnet_ids
}

module "autoscaling" {
  source              = "../../modules/auto-scaling"
  instance_type       = "t2.micro"
  key_name            = "allPurposeVirginia"
  security_group_id   = module.vpc.security_group_id
  appname             = module.vpc.appname
  env                 = module.vpc.env
  vpc_zone_identifier = module.vpc.private_subnet_ids
  vpc_public = module.vpc.public_subnet_ids
}