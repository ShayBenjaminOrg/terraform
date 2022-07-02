# terraform {
#   required_version = ">= 0.12"
# }

# provider "aws" {
#   region = var.aws_region
# }

# data "aws_availability_zones" "available" {}

# # Not required: currently used in conjunction with using
# # icanhazip.com to determine local workstation external IP
# # to open EC2 Security Group access to the Kubernetes cluster.
# # See workstation-external-ip.tf for additional information.
# provider "http" {}

# Kubernetes provider
# https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

# The Kubernetes provider is included in this file so the EKS module can complete successfully. Otherwise, it throws an error when creating `kubernetes_config_map.aws_auth`.
# You should **not** schedule deployments and services in this workspace. This keeps workspaces modular (one for provision EKS, another for scheduling Kubernetes resources) as per best practices.

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
