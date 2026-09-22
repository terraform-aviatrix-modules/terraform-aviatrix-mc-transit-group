module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "transit-vpc"
  cidr = "10.1.0.0/16"

  azs            = ["eu-central-1a", "eu-central-1b"]
  public_subnets = ["10.1.101.0/24", "10.1.102.0/24"]
}

module "transit_aws" {
  source  = "terraform-aviatrix-modules/mc-transit-group/aviatrix"
  version = "9.0.0"

  cloud   = "AWS"
  name    = "transit-aws"
  region  = "eu-central-1"
  account = "AWS"

  use_existing_vpc = true
  vpc_id           = module.vpc.vpc_id

  instances = {
    "transit-aws" = {
      subnet = module.vpc.public_subnets_cidr_blocks[0]
    }
    "transit-aws-2" = {
      subnet = module.vpc.public_subnets_cidr_blocks[1]
    }
  }
}
