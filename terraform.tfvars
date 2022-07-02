//AWS 
region      = "us-east-1"
environment = "dev"
host_os     = "linux"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  //List of Public subnet cidr range
private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"] //List of private subnet cidr range
local_ip             = "46.120.36.231/32"

# Jenkins
JENKINS_ADMIN_ID = "admin"
JENKINS_ADMIN_PASSWORD = "password"

# Ansible
PLAYBOOKS_PATH = "~/projects/ShayBenjaminOrg/ansible/playbooks"

# EKS
eks_module_version = "18.24.1"
cluster_base_name = "eks"
eks_cluster_version = "1.22"

// Add k8s worker groups values
