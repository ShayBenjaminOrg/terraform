resource "random_id" "random_id_prefix" {
  byte_length = 2
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_availability_zones" "available" {}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# # Override with variable or hardcoded value if necessary
# locals {

# }

/*====
Variables used across all modules
======*/
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
  //production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  production_availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)

  module_path        = abspath(path.module)
  codebase_root_path = abspath("${path.module}/../..")
  # Trim local.codebase_root_path and one additional slash from local.module_path
  module_rel_path = substr(local.module_path, length(local.codebase_root_path) + 1, length(local.module_path))

  # Rendering flags
  isAnsibleEnabled    = false
  isJenkinsEnabled    = true
  isPrometheusEnabled = false
  isELKEnabled        = false
  isK8SEnabled        = true
  eks_cluster_name    = "${var.environment}-${var.cluster_base_name}"
  #eks_cluster_name    = "${var.environment}-${var.cluster_base_name}-${random_string.suffix.result}"
}



module "networking" {
  source = "./modules/networking"
  region = var.region
  //local_ip             = var.local_ip
  local_ip             = local.workstation-external-cidr
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
  isPrometheusEnabled  = local.isPrometheusEnabled
  isJenkinsEnabled     = local.isJenkinsEnabled
  isK8SEnabled         = local.isK8SEnabled
  eks_cluster_name     = local.eks_cluster_name
}

module "auth" {
  source      = "./modules/auth"
  environment = var.environment
}

# module "eks_cluster" {
#   source      = "./modules/eks"
#   aws_region  = var.region
#   local_ip    = var.local_ip
#   vpc_id      = module.networking.vpc_id
#   environment = var.environment
#   //vpc_cidr                        = var.vpc_cidr
#   //public_subnets_cidr             = var.public_subnets_cidr
#   private_subnets_cidr = var.private_subnets_cidr
#   private_subnets = module.networking.private_subnets_id
#   //availability_zones              = local.production_availability_zones
#   //isPrometheusEnabled             = local.isPrometheusEnabled
#   //isJenkinsEnabled                = local.isJenkinsEnabled
#   isK8SEnabled                    = local.isK8SEnabled
#   eks_cluster_name                = local.eks_cluster_name
#   eks_module_version              = var.eks_module_version
#   eks_cluster_version             = var.eks_cluster_version
#   eks_worker_group_mgmt_one_sg_id = module.networking.eks_worker_group_mgmt_one_sg_id
#   eks_worker_group_mgmt_two_sg_id = module.networking.eks_worker_group_mgmt_two_sg_id
# }


module "eks" {
  source = "./modules/eks"
  vpc_data = {
    id                  = module.networking.vpc_id
    private_subnets_ids = module.networking.private_subnets_id
    public_subnets_ids  = module.networking.public_subnets_id
  }
  cluster_name = local.eks_cluster_name
  region       = var.region
}



## Security Groups ##


# module "monitoring" {
#   source      = "./modules/monitoring"
#   vpc_id      = module.networking.vpc_id
#   subnet_id   = module.networking.public_subnets_id[0]
#   environment = var.environment
#   key_name    = module.auth.key_name
#   local_ip    = var.local_ip
#   vpc         = module.networking.vpc
#    host_os = var.host_os
# }

module "jenkins" {
  source      = "./modules/jenkins"
  vpc_id      = module.networking.vpc_id
  subnet_id   = module.networking.public_subnets_id[0]
  environment = var.environment
  key_name    = module.auth.key_name
  local_ip    = var.local_ip
  //vpc         = module.networking.vpc
  //prometheus_sg = module.monitoring.prometheus_sg
  host_os                = var.host_os
  JENKINS_ADMIN_ID       = var.JENKINS_ADMIN_ID
  JENKINS_ADMIN_PASSWORD = var.JENKINS_ADMIN_PASSWORD
  PLAYBOOKS_PATH         = var.PLAYBOOKS_PATH
  GIT_PRIVATE_KEY        = var.GIT_PRIVATE_KEY
  GIT_SSH_USERNAME       = var.GIT_SSH_USERNAME
  jenkins_master_sg_id   = module.networking.jenkins_master_sg_id
  jenkins_agent_sg_id    = module.networking.jenkins_agent_sg_id
  AWS_ACCESS_KEY_ID      = var.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY  = var.AWS_SECRET_ACCESS_KEY
}

# module "app" {
#   source      = "./modules/app"
#   vpc_id      = module.networking.vpc_id
#   subnet_id   = module.networking.public_subnets_id[0]
#   environment = var.environment
#   key_name    = module.auth.key_name
#   local_ip    = var.local_ip
#   vpc         = module.networking.vpc
#   //prometheus_sg = module.monitoring.prometheus_sg
#   host_os             = var.host_os
#   //jenkins_agent_sg_id = module.jenkins.jenkins_agent_sg_id
#   PLAYBOOKS_PATH      = var.PLAYBOOKS_PATH
#   app_sg_id           = module.networking.app_sg_id
# }






# module "ansible" {
#   //source      = "${local.local.module_path}/modules/ansible"
#   source        = "./modules/ansible"
#   vpc_id        = module.networking.vpc_id
#   subnet_id     = module.networking.public_subnets_id[0]
#   environment   = var.environment
#   host_os       = var.host_os
#   jenkins_agent_ec2_host = [module.jenkins.jenkins_agent_ec2_host[0]]
# }
