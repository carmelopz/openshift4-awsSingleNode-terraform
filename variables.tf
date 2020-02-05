variable "region" {
  default = "us-east-1"
}

# this ami is for Red Hat Enterprise Linux CoreOS (RHCOS)
# pulled from here: https://github.com/openshift/installer/blob/master/data/data/rhcos-amd64.json
# last updated: 04-02-2020

variable "amis" {
  type = map(string)
  default = {
    "ap-northeast-1" = "ami-0bf6f5f209e5e041a"
    "ap-northeast-2" = "ami-03ae1c65102605f45"
    "ap-south-1"     = "ami-0cb6afbddc63fc2df"
    "ap-southeast-1" = "ami-0d506839070dc244b"
    "ap-southeast-2" = "ami-085848fd4435c94ec"
    "ca-central-1"   = "ami-01b36924502c16d0a"
    "eu-central-1"   = "ami-018420f426fa235e6"
    "eu-north-1"     = "ami-0d787e8fe2b42f20c"
    "eu-west-1"      = "ami-0123a5183598a0ac4"
    "eu-west-2"      = "ami-005192895e65f27d0"
    "eu-west-3"      = "ami-00a1b0be594a38046"
    "me-south-1"     = "ami-085f10932087a3c29"
    "sa-east-1"      = "ami-0f8a6a6d76d7870b8"
    "us-east-1"      = "ami-0c027d6d0a8882303"
    "us-east-2"      = "ami-0a8ba019bc9d4bd64"
    "us-west-1"      = "ami-03d44b77bad14081c"
    "us-west-2"      = "ami-0247e06438c49143e"
  }
}

variable "control_plane" {
  type = map(string)
  default = {
    "instance_type" = "m4.large"
  }
}

variable "worker" {
  type = map(string)
  default = {
    "instance_type" = "m4.large"
  }
}

variable "bootstrap" {
  type = map(string)
  default = {
    "instance_type" = "i3.large"
  }
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["A", "B", "C"]
}

resource "random_string" "random" {
  length           = 6
  special          = true
  override_special = "/@£$"
}

locals {
  full_cluster_name = "trim(${var.cluster_name}, -)-${random_string.random.result}"
}