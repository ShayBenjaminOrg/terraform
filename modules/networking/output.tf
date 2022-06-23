output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnets_id" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "private_subnets_id" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "public_route_table" {
  value = "${aws_route_table.public.id}"
}

output "vpc" {
  value = "${aws_vpc.vpc}"
}

## Security Groups ##
output "jenkins_master_sg_id" {
  value = "${aws_security_group.jenkins_master_sg[0].id}"
}

output "jenkins_agent_sg_id" {
  value = "${aws_security_group.jenkins_agent_sg[0].id}"
}

output "app_sg_id" {
  value = "${aws_security_group.app_sg[0].id}"
}
