//AWS 
region      = "us-east-1"
environment = "dev"
host_os     = "linux"

/* module networking */
vpc_cidr             = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24"]  //List of Public subnet cidr range
private_subnets_cidr = ["10.0.10.0/24"] //List of private subnet cidr range
local_ip             = "77.125.159.24/32"

# Jenkins
JENKINS_ADMIN_ID = "admin"
JENKINS_ADMIN_PASSWORD = "password"

# Ansible
PLAYBOOKS_PATH = "~/projects/ShayBenjaminOrg/ansible/playbooks"

# Rendering flags
# isAnsibleEnabled = false
# isJenkinsEnabled = true
# isPrometheusEnabled = false
# isELKEnabled = false