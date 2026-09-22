terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

provider "aviatrix" {}

module "single_instance" {
  source = "../.."

  cloud     = "aws"
  name      = "transit-single-aws"
  region    = "eu-central-1"
  cidr      = "10.1.0.0/23"
  account   = "AWS"
  instances = { for i in range(1) : "transit-single-aws-${i + 1}" => {} }
}

module "multi_instance" {
  source = "../.."

  cloud     = "aws"
  name      = "transit-multi-aws"
  region    = "eu-central-1"
  cidr      = "10.2.0.0/23"
  account   = "AWS"
  instances = { for i in range(2) : "transit-multi-aws-${i + 1}" => {} }
}

module "explicit_instances" {
  source = "../.."

  cloud   = "aws"
  name    = "transit-explicit-aws"
  region  = "eu-central-1"
  cidr    = "10.3.0.0/23"
  account = "AWS"

  instances = {
    "transit-explicit-aws-1" = {}
    "transit-explicit-aws-2" = {}
  }
}

resource "test_assertions" "cloud_type_single" {
  component = "cloud_type_single"

  equal "cloud_type" {
    description = "Cloud type is AWS."
    got         = module.single_instance.transit_group.cloud_type
    want        = 1
  }
}

resource "test_assertions" "cloud_type_multi" {
  component = "cloud_type_multi"

  equal "cloud_type" {
    description = "Cloud type is AWS."
    got         = module.multi_instance.transit_group.cloud_type
    want        = 1
  }
}

resource "test_assertions" "instance_count_multi" {
  component = "instance_count_multi"

  equal "instance_count" {
    description = "Two instances created."
    got         = length(module.multi_instance.transit_instances)
    want        = 2
  }
}

resource "test_assertions" "instance_count_explicit" {
  component = "instance_count_explicit"

  equal "instance_count" {
    description = "Two explicit instances created."
    got         = length(module.explicit_instances.transit_instances)
    want        = 2
  }
}
