# #### Jenkins SG ####
# resource "aws_security_group" "jenkins_master_sg" {
#   count       = var.isJenkinsEnabled ? 1 : 0

#   name        = "${var.environment}_jenkins_master_sg"
#   description = "Default security group to allow inbound/outbound from the VPC"
#   vpc_id      = aws_vpc.vpc.id
#   depends_on  = [aws_vpc.vpc]


#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["${var.local_ip}"]
#     //security_groups = [var.prometheus_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }

# resource "aws_security_group" "jenkins_agent_sg" {
#   count       = var.isJenkinsEnabled ? 1 : 0
  
#   name        = "${var.environment}_jenkins_agent_sg"
#   description = "Default security group to allow inbound/outbound to jenkins agents"
#   vpc_id      = aws_vpc.vpc.id
#   depends_on  = [aws_vpc.vpc]



#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     self            = true
#     security_groups = [aws_security_group.jenkins_master_sg[0].id]
#     //security_groups = [aws_security_group.jenkins_master_sg.id, var.prometheus_sg.id]
#     //cidr_blocks = ["${var.local_ip}"]
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }


# resource "aws_security_group_rule" "jenkins_master_ingress" {
#   count       = var.isJenkinsEnabled ? 1 : 0

#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"
#   security_group_id        = aws_security_group.jenkins_master_sg[0].id
#   source_security_group_id = aws_security_group.jenkins_agent_sg[0].id
#   depends_on               = [aws_security_group.jenkins_master_sg[0], aws_security_group.jenkins_agent_sg[0]]
# }

# ###################


# #### WebApp SG ####
# resource "aws_security_group" "app_sg" {
#   count       = var.isJenkinsEnabled ? 1 : 0
#   name        = "${var.environment}_app_sg"
#   description = "Default security group to allow inbound/outbound to app"
#   vpc_id      = aws_vpc.vpc.id
#   depends_on  = [aws_vpc.vpc]
  
 

#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     self            = true
#     //security_groups = [aws_security_group.jenkins_master_sg.id]
#     security_groups = [aws_security_group.jenkins_agent_sg[0].id]
#     cidr_blocks = ["${var.local_ip}"]
#     //cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }

# ###################




# #### Prometheus & Grafana SG ####
# resource "aws_security_group" "prometheus_sg" {
#   count = var.isPrometheusEnabled ? 1 : 0

#   name        = "${var.environment}_prometheus_sg"
#   description = "Default security group to allow inbound/outbound from the VPC"
#   vpc_id      = aws_vpc.vpc.id
#   depends_on  = [aws_vpc.vpc]


#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["${var.local_ip}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }

# resource "aws_security_group" "grafana_sg" {
#   count       = var.isPrometheusEnabled ? 1 : 0
#   name        = "${var.environment}_grafana_sg"
#   description = "Default security group to allow inbound/outbound to grafana"
#   vpc_id      = aws_vpc.vpc.id
#   depends_on  = [aws_vpc.vpc]



#   ingress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     self            = true
#     security_groups = [aws_security_group.prometheus_sg[0].id]
#     cidr_blocks     = ["${var.local_ip}"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }

# ###################

# #### EKS SG ####

# # resource "aws_security_group" "eks_worker_group_mgmt_one" {
# #   count       = var.isK8SEnabled ? 1 : 0
# #   name_prefix = "eks_worker_group_mgmt_one"
# #   vpc_id      = aws_vpc.vpc.id

# #   ingress {
# #     from_port = 22
# #     to_port   = 22
# #     protocol  = "tcp"

# #     cidr_blocks = [
# #       "10.0.0.0/8",
# #     ]
# #   }
# # }

# # resource "aws_security_group" "eks_worker_group_mgmt_two" {
# #   count       = var.isK8SEnabled ? 1 : 0
# #   name_prefix = "eks_worker_group_mgmt_two"
# #   vpc_id      = aws_vpc.vpc.id

# #   ingress {
# #     from_port = 22
# #     to_port   = 22
# #     protocol  = "tcp"

# #     cidr_blocks = [
# #       "192.168.0.0/16",
# #     ]
# #   }
# # }

# # resource "aws_security_group" "eks_all_worker_mgmt" {
# #   count       = var.isK8SEnabled ? 1 : 0
# #   name_prefix = "eks_all_worker_management"
# #   vpc_id      = aws_vpc.vpc.id

# #   ingress {
# #     from_port = 22
# #     to_port   = 22
# #     protocol  = "tcp"

# #     cidr_blocks = [
# #       "10.0.0.0/8",
# #       "172.16.0.0/12",
# #       "192.168.0.0/16",
# #     ]
# #   }
# # }



# ###################