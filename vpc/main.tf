locals {
  private_cidr_range = cidrsubnet(aws_vpc.vpc.cidr_block, 1, 1)
  public_cidr_range  = cidrsubnet(aws_vpc.vpc.cidr_block, 1, 0)
  az_set             = toset(var.availability_zones)
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" = "${var.cluster_name}-vpc"
    },
    var.tags,
  )
}
