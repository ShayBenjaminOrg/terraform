# data "aws_ami" "server_ami" {
#   most_recent = true
#   owners      = ["137112412989"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.*"]
#   }
# }

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}