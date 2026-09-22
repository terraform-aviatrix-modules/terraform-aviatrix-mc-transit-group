# terraform-aviatrix-mc-transit-group release notes

## 9.0.0
### Initial release
Initial release of the mc-transit-group module, built on the `aviatrix_transit_group` and `aviatrix_transit_instance` resources introduced in controller 9.0.

This module replaces the primary+HA gateway pair model used by `mc-transit` with a group model that allows horizontal scaling by adding instances to the group independently of the group-level policy.

### Features
- Multi-cloud support (AWS, Azure, GCP, OCI, Alibaba)
- Flexible instance map — deploy one or many gateway instances per group
- Per-instance overrides for size, subnet, zone, tags, HPE, BGP over LAN, and more
- Module-level defaults for common settings (tags, insane_mode, tunnel_detection_time, etc.)
- FireNet and Transit FireNet support (including GCP LAN VPC)
- Connected transit, hybrid connection, segmentation
- Private network deployment (AWS, Azure) — gateways without public IPs
- BGP, BGP over LAN, BGP ECMP, learned CIDRs approval
- Active-standby mode
- Multi-tier transit, Gateway Load Balancer
- Edge transit support (EDGETRANSIT gateway type)
- mc-firenet integration output for composing with the mc-firenet module
