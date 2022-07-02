variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  default = "getting-started-eks"
}

# variable "map_accounts" {
#   description = "Additional AWS account numbers to add to the aws-auth configmap."
#   type        = list(string)

#   default = [
#     "777777777777",
#     "888888888888",
#   ]
# }

# variable "map_roles" {
#   description = "Additional IAM roles to add to the aws-auth configmap."
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#     {
#       rolearn  = "arn:aws:iam::66666666666:role/role1"
#       username = "role1"
#       groups   = ["system:masters"]
#     },
#   ]
# }

# variable "map_users" {
#   description = "Additional IAM users to add to the aws-auth configmap."
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#     {
#       userarn  = "arn:aws:iam::66666666666:user/user1"
#       username = "user1"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::66666666666:user/user2"
#       username = "user2"
#       groups   = ["system:masters"]
#     },
#   ]
# }

# variable "subnet_id_1" {
#   type = string
#   default = "subnet-your_first_subnet_id"
#  }
 
#  variable "subnet_id_2" {
#   type = string
#   default = "subnet-your_second_subnet_id"
#  }

variable "vpc_data" {
  type = object({
    id = string
    private_subnets_ids = list(string)
    public_subnets_ids = list(string)
  })
  # default = {
  #   id = ""
  #   private_subnets_ids = []
  #   public_subnets_ids = []
  # }
  validation {
    condition     = length(var.vpc_data.id) > 0
    error_message = "VPC ID must be supplied"
  }
}