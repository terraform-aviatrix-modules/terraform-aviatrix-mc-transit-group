module "transit_aws" {
  source  = "terraform-aviatrix-modules/mc-transit-group/aviatrix"
  version = "9.0.0"

  cloud   = "AWS"
  name    = "transit-aws"
  cidr    = "10.1.0.0/23"
  region  = "eu-west-3"
  account = "AWS"
  instances = {
    "transit-aws"   = {}
    "transit-aws-2" = {}
  }
}
