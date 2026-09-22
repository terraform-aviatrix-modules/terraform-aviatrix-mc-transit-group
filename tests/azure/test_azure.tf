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

  cloud     = "azure"
  name      = "transit-single-azure"
  region    = "West Europe"
  cidr      = "10.1.0.0/23"
  account   = "Azure"
  instances = { for i in range(1) : "transit-single-azure-${i + 1}" => {} }
}

module "multi_instance" {
  source = "../.."

  cloud     = "azure"
  name      = "transit-multi-azure"
  region    = "West Europe"
  cidr      = "10.2.0.0/23"
  account   = "Azure"
  instances = { for i in range(2) : "transit-multi-azure-${i + 1}" => {} }
}

resource "test_assertions" "cloud_type_single" {
  component = "cloud_type_single"

  equal "cloud_type" {
    description = "Cloud type is Azure."
    got         = module.single_instance.transit_group.cloud_type
    want        = 8
  }
}

resource "test_assertions" "cloud_type_multi" {
  component = "cloud_type_multi"

  equal "cloud_type" {
    description = "Cloud type is Azure."
    got         = module.multi_instance.transit_group.cloud_type
    want        = 8
  }
}
