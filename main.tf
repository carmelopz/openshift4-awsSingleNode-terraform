provider "aws" {
  region = var.region
}

locals {
  ami          = var.amis[var.region]
  cluster_name = local.full_cluster_name
  tags = merge(var.tags, {
    owned-by = "local.cluster_name"
  })
}

module "bootstrap" {
  source = "./bootstrap"

  ami       = local.ami
  subnet_id = module.vpc.private_subnets[var.availability_zones[0]].id
  tags      = local.tags
  type      = var.bootstrap.instance_type
}

module "controlPlane" {
  source = "./controlPlane"

  ami = local.ami
}

module "route53" {
  source = "./route53"
}

module "vpc" {
  source = "./vpc"

  tags               = local.tags
  vpc_cidr_block     = var.vpc_cidr_block
  cluster_name       = local.cluster_name
  availability_zones = var.availability_zones
}
