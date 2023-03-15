output "security_group_id" {
  value = module.vpc.security_group_id
}

# output "loadbalancer_dns" {
#   value = module.vpc.loadbalancer_dns  
# }

# output "debug" {
#   value = module.loadbalancer.aws_lb_target_group_arns
# }