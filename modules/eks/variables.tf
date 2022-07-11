variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  default = "getting-started-eks"
}

variable "vpc_data" {
  type = object({
    id = string
    private_subnets_ids = list(string)
    public_subnets_ids = list(string)
  })
  validation {
    condition     = length(var.vpc_data.id) > 0
    error_message = "VPC ID must be supplied"
  }
}