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

  cloud     = "gcp"
  name      = "transit-single-gcp"
  region    = "us-east1"
  cidr      = "10.1.0.0/23"
  account   = "GCP"
  instances = { for i in range(1) : "transit-single-gcp-${i + 1}" => {} }
}

module "multi_instance" {
  source = "../.."

  cloud     = "gcp"
  name      = "transit-multi-gcp"
  region    = "us-east1"
  cidr      = "10.2.0.0/23"
  account   = "GCP"
  instances = { for i in range(2) : "transit-multi-gcp-${i + 1}" => {} }
}

resource "test_assertions" "cloud_type_single" {
  component = "cloud_type_single"

  equal "cloud_type" {
    description = "Cloud type is GCP."
    got         = module.single_instance.transit_group.cloud_type
    want        = 4
  }
}

resource "test_assertions" "cloud_type_multi" {
  component = "cloud_type_multi"

  equal "cloud_type" {
    description = "Cloud type is GCP."
    got         = module.multi_instance.transit_group.cloud_type
    want        = 4
  }
}
