variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "local_ip" {
  description = "Local IP for ingress"
}

variable "JENKINS_ADMIN_ID" {
  description = "JENKINS_ADMIN_ID"
}

variable "JENKINS_ADMIN_PASSWORD" {
  description = "JENKINS_ADMIN_PASSWORD"
}

variable "host_os" {
  type    = string
  default = "linux"
}

variable "PLAYBOOKS_PATH" {
  type = string
}

variable "GIT_PRIVATE_KEY" {}

variable "GIT_SSH_USERNAME" {}

variable "eks_module_version" {}
variable "cluster_base_name" {}
variable "eks_cluster_version" {}
