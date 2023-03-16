output "vpc_id" {
  value = aws_vpc.main-vpc.id
}

output "security_group_id" {
  value = aws_security_group.main-sg.id
}

output "appname" {
  value = var.appname
}

output "env" {
  value = var.env
}

output "private_subnet_ids" {
  value = aws_subnet.private_sub[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_sub[*].id
}
