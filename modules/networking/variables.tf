variable "environment" {
  description = "The Deployment environment"
}

variable "local_ip" {
  description = "Local IP for ingress"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zones" {
  type        = list
  description = "The az that the resources will be launched"
}

variable "isPrometheusEnabled" {
  type        = bool
  default = false
}

variable "isJenkinsEnabled" {
  type        = bool
  default = false
}

variable "isK8SEnabled" {
  type        = bool
  default = false
}

variable "eks_cluster_name" {}