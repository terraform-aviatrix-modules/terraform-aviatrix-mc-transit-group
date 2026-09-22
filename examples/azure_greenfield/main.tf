module "transit_azure" {
  source  = "terraform-aviatrix-modules/mc-transit-group/aviatrix"
  version = "9.0.0"

  cloud    = "Azure"
  name     = "transit-azure"
  cidr     = "10.1.0.0/23"
  region   = "West Europe"
  account  = "Azure"
  instances = {
    "transit-azure"    = {}
    "transit-azure-2" = {}
  }
}
