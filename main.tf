provider "aws" {
  region  = var.region
}

module "bootstrap" {
  source "./bootstrap"
}

module "controlPlane" {
  source "./controlPlane"
}

module "route53" {
  source "./route53"
}

module "vpc" {
  source "./vpc"
}
