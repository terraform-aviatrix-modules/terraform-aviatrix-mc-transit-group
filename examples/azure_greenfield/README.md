### Usage Example Azure Greenfield

In this example, a simple Azure transit group is deployed with two gateways in a new VNet.

```hcl
module "transit_azure" {
  source  = "terraform-aviatrix-modules/mc-transit-group/aviatrix"
  version = "9.0.0"

  cloud    = "Azure"
  name     = "transit-azure"
  cidr     = "10.1.0.0/23"
  region   = "West Europe"
  account  = "Azure"
  instances = {
    "transit-azure"   = {}
    "transit-azure-2" = {}
  }
}
```
