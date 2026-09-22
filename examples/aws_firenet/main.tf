module "transit_firenet_aws" {
  source  = "terraform-aviatrix-modules/mc-transit-group/aviatrix"
  version = "9.0.0"

  cloud                  = "AWS"
  name                   = "transit-firenet-aws"
  cidr                   = "10.1.0.0/23"
  region                 = "eu-west-1"
  account                = "AWS"
  enable_transit_firenet = true
  enable_segmentation    = true
  instances = {
    "transit-firenet-aws"    = {}
    "transit-firenet-aws-2" = {}
  }
}
