
# data "aws_availability_zones" "available" {}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "3.12.0"

#   name = local.cluster_name
#   cidr = local.vpc_cidr
#   azs  = local.azs
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

#   enable_nat_gateway     = true
#   single_nat_gateway     = true
#   one_nat_gateway_per_az = false

#   private_subnet_tags = {
#     "kubernetes.io/cluster/${local.cluster_name}" = "owned"
#     # Tags subnets for Karpenter auto-discovery
#     "karpenter.sh/discovery" = local.cluster_name
#   }

#   tags = local.tags
# }


module "eks" {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "18.17.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.22"

  vpc_id     = var.vpc_data.id
  subnet_ids = var.vpc_data.private_subnets_ids
  # vpc_id     = module.vpc.vpc_id
  # subnet_ids = module.vpc.private_subnets

  # Required for Karpenter role below
  # Determines whether to create an OpenID Connect Provider for EKS to enable IRSA
  enable_irsa = true

  # We will rely only on the cluster security group created by the EKS service
  # See note below for `tags`
  # Determines if a security group is created for the cluster or use the existing `cluster_security_group_id`
  create_cluster_security_group = false
  
  # Determines whether to create a security group for the node groups or use the existing `node_security_group_id`
  create_node_security_group    = false

  # Only need one node to get Karpenter up and running.
  # This ensures core services such as VPC CNI, CoreDNS, etc. are up and running
  # so that Karpetner can be deployed and start managing compute capacity as required
  # Map of EKS managed node group definitions to create
  eks_managed_node_groups = {
    # managed_node_groups configurations listed in https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/18.17.0/submodules/eks-managed-node-group?tab=inputs

    initial = {
      # Set of instance types associated with the EKS Node Group. Defaults to `["t3.medium"]`
      instance_types = ["t3.medium"]
      # We don't need the node security group since we are using the
      # cluster-created security group, which Karpenter will also use
      # Determines whether to create a security group
      create_security_group                 = false
      attach_cluster_primary_security_group = true

      # Minimum number of instances/nodes
      min_size     = 1
      # Maximum number of instances/nodes
      max_size     = 1

      # Desired number of instances/nodes
      desired_size = 1

      # Additional policies to be added to the IAM role
      iam_role_additional_policies = [
        # Required by Karpenter
        "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }

  # List of additional security group rules to add to the cluster security group created.
  # Set `source_node_security_group = true` inside rules to set the `node_security_group` as source
  cluster_security_group_additional_rules = {
    ingress_nodes_karpenter_ports_tcp = {
      description                = "Karpenter readiness"
      protocol                   = "tcp"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
  }
  
  # List of additional security group rules to add to the node security group created.
  # Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source
  node_security_group_additional_rules = {
    aws_lb_controller_webhook = {
      description                   = "Cluster API to AWS LB Controller webhook"
      protocol                      = "all"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }  

  tags = {
    # Tag node group resources for Karpenter auto-discovery
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    "karpenter.sh/discovery" = local.cluster_name
  }
}











# resource "aws_eks_cluster" "devopsthehardway-eks" {
#  name = "devopsthehardway-cluster"
#  role_arn = aws_iam_role.eks-iam-role.arn

#  vpc_config {
#   subnet_ids = module.vpc.private_subnets
#  }

#  depends_on = [
#   aws_iam_role.eks-iam-role,
#  ]
# }

# provider "kubernetes" {
#   host                   = module.eks_blueprints.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
#   }
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks_blueprints.eks_cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
#     }
#   }
# }


#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

# module "eks_blueprints" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints"

#   cluster_name    = local.name
#   cluster_version = "1.22"

#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnets

#   managed_node_groups = {
#     mg_5 = {
#       node_group_name = "managed-ondemand"
#       instance_types  = ["m5.large"]
#       min_size        = 2
#       subnet_ids      = module.vpc.private_subnets
#     }
#   }

#   tags = local.tags
# }

# module "eks_blueprints_kubernetes_addons" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

#   eks_cluster_id       = module.eks_blueprints.eks_cluster_id
#   eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
#   eks_oidc_provider    = module.eks_blueprints.oidc_provider
#   eks_cluster_version  = module.eks_blueprints.eks_cluster_version

#   # EKS Managed Add-ons
#   enable_amazon_eks_coredns    = true
#   enable_amazon_eks_kube_proxy = true

#   # Add-ons
#   enable_metrics_server               = true
#   enable_cluster_autoscaler           = true
#   enable_aws_load_balancer_controller = true

#   enable_ingress_nginx = true
#   ingress_nginx_helm_config = {
#     version = "4.0.17"
#     values  = [templatefile("${path.module}/assets/nginx_values.yaml", {})]
#   }

#   tags = local.tags
# }


#---------------------------------------------------------------
# END EKS Blueprints 
#---------------------------------------------------------------

#---------------------------------------------------------------
# VPC
#---------------------------------------------------------------



#---------------------------------------------------------------
# END VPC
#---------------------------------------------------------------






# data "aws_caller_identity" "current" {}

# module "eks" {
#   source                          = "terraform-aws-modules/eks/aws"
#   cluster_name                    = var.cluster_name
#   cluster_version                 = local.cluster_version
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   # IPV6
#   cluster_ip_family = "ipv6"

#   # We are using the IRSA created below for permissions
#   # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
#   # and then turn this off after the cluster/node group is created. Without this initial policy,
#   # the VPC CNI fails to assign IPs and nodes cannot join the cluster
#   # See https://github.com/aws/containers-roadmap/issues/1666 for more context
#   # TODO - remove this policy once AWS releases a managed version similar to AmazonEKS_CNI_Policy (IPv4)
#   create_cni_ipv6_iam_policy = true

#   cluster_addons = {
#     coredns = {
#       resolve_conflicts = "OVERWRITE"
#     }
#     kube-proxy = {}
#     vpc-cni = {
#       resolve_conflicts        = "OVERWRITE"
#       service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
#     }
#   }

#   cluster_encryption_config = [{
#     provider_key_arn = aws_kms_key.eks.arn
#     resources        = ["secrets"]
#   }]

#   cluster_tags = {
#     # This should not affect the name of the cluster primary security group
#     # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2006
#     # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2008
#     Name = local.name
#   }

#   vpc_id = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   manage_aws_auth_configmap = true

#   # Extend cluster security group rules
#   cluster_security_group_additional_rules = {
#     egress_nodes_ephemeral_ports_tcp = {
#       description                = "To node 1025-65535"
#       protocol                   = "tcp"
#       from_port                  = 1025
#       to_port                    = 65535
#       type                       = "egress"
#       source_node_security_group = true
#     }
#   }

#   # Extend node-to-node security group rules
#   node_security_group_ntp_ipv4_cidr_block = ["fd00:ec2::123/128"]
#   node_security_group_additional_rules = {
#     ingress_self_all = {
#       description = "Node to node all ports/protocols"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       self        = true
#     }
#     egress_all = {
#       description      = "Node all egress"
#       protocol         = "-1"
#       from_port        = 0
#       to_port          = 0
#       type             = "egress"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = ["::/0"]
#     }
#   }

#   eks_managed_node_group_defaults = {
#     ami_type       = "AL2_x86_64"
#     instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]

#     # We are using the IRSA created below for permissions
#     # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
#     # and then turn this off after the cluster/node group is created. Without this initial policy,
#     # the VPC CNI fails to assign IPs and nodes cannot join the cluster
#     # See https://github.com/aws/containers-roadmap/issues/1666 for more context
#     iam_role_attach_cni_policy = true
#   }

#   eks_managed_node_groups = {

#     # Default node group - as provided by AWS EKS
#     default_node_group = {
#       # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
#       # so we need to disable it to use the default template provided by the AWS EKS managed node group service
#       create_launch_template = false
#       launch_template_name   = ""

#       disk_size = 50

#       # Remote access cannot be specified with a launch template
#       remote_access = {
#         ec2_ssh_key               = aws_key_pair.this.key_name
#         source_security_group_ids = [aws_security_group.remote_access.id]
#       }
#     }

#     # Default node group - as provided by AWS EKS using Bottlerocket
#     bottlerocket_default = {
#       # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
#       # so we need to disable it to use the default template provided by the AWS EKS managed node group service
#       create_launch_template = false
#       launch_template_name   = ""

#       ami_type = "BOTTLEROCKET_x86_64"
#       platform = "bottlerocket"
#     }

#     # Adds to the AWS provided user data
#     bottlerocket_add = {
#       ami_type = "BOTTLEROCKET_x86_64"
#       platform = "bottlerocket"

#       # this will get added to what AWS provides
#       bootstrap_extra_args = <<-EOT
#       # extra args added
#       [settings.kernel]
#       lockdown = "integrity"
#       EOT
#     }

#     # Custom AMI, using module provided bootstrap data
#     bottlerocket_custom = {
#       # Current bottlerocket AMI
#       ami_id   = data.aws_ami.eks_default_bottlerocket.image_id
#       platform = "bottlerocket"

#       # use module user data template to boostrap
#       enable_bootstrap_user_data = true
#       # this will get added to the template
#       bootstrap_extra_args = <<-EOT
#       # extra args added
#       [settings.kernel]
#       lockdown = "integrity"
#       [settings.kubernetes.node-labels]
#       "label1" = "foo"
#       "label2" = "bar"
#       [settings.kubernetes.node-taints]
#       "dedicated" = "experimental:PreferNoSchedule"
#       "special" = "true:NoSchedule"
#       EOT
#     }


#   }






#   //subnets                         = module.vpc.private_subnets
#   version                         = "18.26.1"
#   cluster_create_timeout          = "1h"
#   //cluster_endpoint_private_access = true

#   //vpc_id = module.vpc.vpc_id

#   worker_groups = [
#     {
#       name                          = "worker-group-1"
#       instance_type                 = "t2.small"
#       additional_userdata           = "echo foo bar"
#       asg_desired_capacity          = 1
#       additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#     },
#   ]

#   worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
#   map_roles                            = var.map_roles
#   map_users                            = var.map_users
#   map_accounts                         = var.map_accounts
# }




# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_availability_zones" "available" {
# }

# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
# }

# resource "aws_security_group" "all_worker_mgmt" {
#   name_prefix = "all_worker_management"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#       "172.16.0.0/12",
#       "192.168.0.0/16",
#     ]
#   }
# }

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "3.14.2"

#   name                 = "test-vpc"
#   cidr                 = "10.0.0.0/16"
#   azs                  = data.aws_availability_zones.available.names
#   private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
#   enable_nat_gateway   = false
#   single_nat_gateway   = false
#   enable_dns_hostnames = true

#   public_subnet_tags = {
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
#     "kubernetes.io/role/elb"                    = "1"
#   }

#   private_subnet_tags = {
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
#     "kubernetes.io/role/internal-elb"           = "1"
#   }

#   vpc_tags = {
#     Name = "vpc-name"
#   }
# }







# resource "kubernetes_deployment" "example" {
#   metadata {
#     name = "terraform-example"
#     labels = {
#       test = "MyExampleApp"
#     }
#   }

#   spec {
#     replicas = 2

#     selector {
#       match_labels = {
#         test = "MyExampleApp"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           test = "MyExampleApp"
#         }
#       }

#       spec {
#         container {
#           image = "nginx:1.7.8"
#           name  = "example"

#           resources {
#             limits {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "example" {
#   metadata {
#     name = "terraform-example"
#   }
#   spec {
#     selector = {
#       test = "MyExampleApp"
#     }
#     port {
#       port        = 80
#       target_port = 80
#     }

#     type = "LoadBalancer"
#   }
# }
