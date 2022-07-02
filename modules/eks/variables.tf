variable "aws_region" {
  default = "us-east-1"
}

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = string
}


variable "instance_type" {
  description = "EC2 instace type"
  default = "t2.micro"
}

variable "vpc_id" {
  description = "VPC id"
}

# variable "subnet_id" {
#   description = "SubnetId for instance"
# }

variable "environment" {
  description = "The Deployment environment"
}

variable "local_ip" {
  description = "Local IP for ingress"
}

variable "prometheus_sg" {
  default = "default"
  description = "Prometheus sg for monitoring"
}

variable "host_os" {
  type    = string
  default = "linux"
}

variable "eks_module_version" {
  description = "eks_module_version"
}

variable "eks_cluster_version" {
  description = "cluster_version"
}

variable "eks_cluster_name" {
  description = "eks_cluster_name"
}

variable "isK8SEnabled" {
  description = "isK8SEnabled"
}



variable "private_subnets_cidr" {
  type = list
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

## Security Groups ##

variable "eks_worker_group_mgmt_one_sg_id" {}
variable "eks_worker_group_mgmt_two_sg_id" {}

# variable "jenkins_master_sg_id" {
#   description = "jenkins_master_sg_id"
# }

# variable "jenkins_agent_sg_id" {
#   description = "jenkins_agent_sg_id"
# }


