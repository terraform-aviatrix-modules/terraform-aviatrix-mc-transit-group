### Usage Example GCP BGP over LAN

In this example, a GCP transit group is deployed with BGP over LAN enabled and two LAN interfaces per gateway.

```hcl
module "transit_gcp" {
  source  = "terraform-aviatrix-modules/mc-transit-group/aviatrix"
  version = "9.0.0"

  cloud           = "GCP"
  name            = "transit-gcp"
  instance_size   = "n2-highcpu-4"
  cidr            = "10.1.0.0/23"
  region          = "us-east1"
  account         = "GCP"
  local_as_number = "65101"

  enable_bgp_over_lan = true

  instances = {
    "transit-gcp" = {
      enable_bgp_over_lan      = true
      bgp_lan_interfaces_count = 2
    }
    "transit-gcp-2" = {
      enable_bgp_over_lan      = true
      bgp_lan_interfaces_count = 2
    }
  }
}
```
