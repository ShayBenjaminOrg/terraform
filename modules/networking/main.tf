module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"

  name            = "${var.environment}-vpc"
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  public_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "private_kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    # Tags subnets for Karpenter auto-discovery
    "private_karpenter.sh/discovery" = var.eks_cluster_name
  }

  public_subnet_tags = {
    "public_kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
    # Tags subnets for Karpenter auto-discovery
    "public_karpenter.sh/discovery" = var.eks_cluster_name
  }

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}



# resource "aws_vpc" "vpc" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = merge(
#     {
#       Name        = "${var.environment}-vpc",
#       Environment = "${var.environment}"
#     },
#   [var.isK8SEnabled ? { "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" } : null]...)
# }

# /*====
# Subnets
# ======*/
# /* Internet gateway for the public subnet */
# resource "aws_internet_gateway" "ig" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name        = "${var.environment}-igw"
#     Environment = "${var.environment}"
#   }
# }

# /* Elastic IP for NAT */
# # resource "aws_eip" "nat_eip" {
# #   vpc        = true
# #   depends_on = [aws_internet_gateway.ig]
# # }

# # # /* NAT */
# # resource "aws_nat_gateway" "nat" {
# #   allocation_id = "${aws_eip.nat_eip.id}"
# #   subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
# #   depends_on    = [aws_internet_gateway.ig]

# #   tags = {
# #     Name        = "nat"
# #     Environment = "${var.environment}"
# #   }
# # }

# /* Public subnet */
# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.vpc.id
#   count                   = length(var.public_subnets_cidr)
#   cidr_block              = element(var.public_subnets_cidr, count.index)
#   availability_zone       = element(var.availability_zones, count.index)
#   map_public_ip_on_launch = true

#   # tags = {
#   #   Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
#   #   Environment = "${var.environment}"
#   # }

#   tags = merge(
#     {
#       Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet",
#       Environment = "${var.environment}"
#     },
#   [var.isK8SEnabled ? { "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared", "kubernetes.io/role/elb" = "1" } : null]...)
# }

# /* Private subnet */
# resource "aws_subnet" "private_subnet" {
#   vpc_id                  = aws_vpc.vpc.id
#   count                   = length(var.private_subnets_cidr)
#   cidr_block              = element(var.private_subnets_cidr, count.index)
#   availability_zone       = element(var.availability_zones, count.index)
#   map_public_ip_on_launch = false

#   tags = {
#     Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
#     Environment = "${var.environment}"
#   }
# }

# /* Routing table for private subnet */
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.vpc.id

#   # tags = {
#   #   Name        = "${var.environment}-private-route-table"
#   #   Environment = "${var.environment}"
#   # }

#   tags = merge(
#     {
#       Name        = "${var.environment}-private-route-table",
#       Environment = "${var.environment}"
#     },
#   [var.isK8SEnabled ? { "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared", "kubernetes.io/role/internal-elb" = "1" } : null]...)

# }

# /* Routing table for public subnet */
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name        = "${var.environment}-public-route-table"
#     Environment = "${var.environment}"
#   }
# }

# resource "aws_route" "public_internet_gateway" {
#   route_table_id         = aws_route_table.public.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.ig.id
# }

# # resource "aws_route" "private_nat_gateway" {
# #   route_table_id         = aws_route_table.private.id
# #   destination_cidr_block = "0.0.0.0/0"
# #   nat_gateway_id         = "${aws_nat_gateway.nat.id}"
# #   //gateway_id = aws_internet_gateway.ig.id
# # }

# /* Route table associations */
# resource "aws_route_table_association" "public" {
#   count          = length(var.public_subnets_cidr)
#   subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "private" {
#   count          = length(var.private_subnets_cidr)
#   subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
#   route_table_id = aws_route_table.private.id
# }



####  K8S  ####

# resource "aws_subnet" "eks" {
#   count = 2

#   availability_zone = element(var.availability_zones, count.index)
#   //availability_zone       = data.aws_availability_zones.available.names[count.index]
#   cidr_block              = "10.0.${count.index}.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = aws_vpc.vpc.id

#   tags = tomap({
#     "Name"                                      = "terraform-eks-demo-node",
#     "kubernetes.io/cluster/${var.cluster-name}" = "shared",
#     "Environment"                               = "${var.environment}"
#   })
# }

###############



/*====
VPC's Default Security Group
======*/
# resource "aws_security_group" "general_sg" {
#   name        = "${var.environment}-general-sg"
#   description = "Default security group to allow inbound/outbound from the VPC"
#   vpc_id      = "${aws_vpc.vpc.id}"
#   depends_on  = [aws_vpc.vpc]

#   ingress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     self      = true
#     cidr_blocks = ["${var.local_ip}"]
#   }

#   egress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     self      = "true"
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }
