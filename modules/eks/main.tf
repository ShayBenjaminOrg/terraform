module "eks" {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.22"

  vpc_id     = var.vpc_data.id
  subnet_ids = var.vpc_data.private_subnets_ids

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
    "karpenter.sh/discovery" = var.cluster_name
  }
}


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
