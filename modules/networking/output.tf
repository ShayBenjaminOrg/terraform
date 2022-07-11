output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_id" {
  value = module.vpc.public_subnets
}

output "private_subnets_id" {
  value = module.vpc.private_subnets
}

## Security Groups ##
output "jenkins_master_sg_id" {
  value = (var.isJenkinsEnabled ? aws_security_group.jenkins_master_sg[0].id : null)
}

output "jenkins_agent_sg_id" {
  value = (var.isJenkinsEnabled ? aws_security_group.jenkins_agent_sg[0].id : null)
}

# output "app_sg_id" {
#   value = (var.isJenkinsEnabled ? aws_security_group.app_sg[0].id : null)
# }

