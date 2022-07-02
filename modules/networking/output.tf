output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_id" {
  value = module.vpc.public_subnets
}

output "private_subnets_id" {
  value = module.vpc.private_subnets
}

# output "vpc_id" {
#   value = aws_vpc.vpc.id
# }

# output "public_subnets_id" {
#   value = ["${aws_subnet.public_subnet.*.id}"]
# }

# output "private_subnets_id" {
#   value = "${aws_subnet.private_subnet.*.id}"
# }

# output "private_subnets" {
#   value = ["${aws_subnet.private_subnet.*}"]
# }

# output "public_route_table" {
#   value = aws_route_table.public.id
# }

# output "vpc" {
#   value = aws_vpc.vpc
# }

## Security Groups ##
# output "jenkins_master_sg_id" {
#   value = (var.isJenkinsEnabled ? aws_security_group.jenkins_master_sg[0].id : null)
# }

# output "jenkins_agent_sg_id" {
#   value = (var.isJenkinsEnabled ? aws_security_group.jenkins_agent_sg[0].id : null)
# }

# output "app_sg_id" {
#   value = (var.isJenkinsEnabled ? aws_security_group.app_sg[0].id : null)
# }


# output "eks_worker_group_mgmt_one_sg_id" {
#   value = (var.isK8SEnabled ? aws_security_group.eks_worker_group_mgmt_one[0].id : null)
# }

# output "eks_worker_group_mgmt_two_sg_id" {
#   value = (var.isK8SEnabled ? aws_security_group.eks_worker_group_mgmt_two[0].id : null)
# }

# output "eks_all_worker_mgmt_sg_id" {
#   value = (var.isK8SEnabled ? aws_security_group.eks_all_worker_mgmt[0].id : null)
# }
