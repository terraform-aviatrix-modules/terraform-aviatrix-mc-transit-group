output "vpc" {
  description = "The created VPC object. Null when use_existing_vpc is true."
  value       = var.use_existing_vpc ? null : aviatrix_vpc.default[0]
}

output "lan_vpc" {
  description = "The GCP LAN VPC object for Transit FireNet. Null when not GCP or transit firenet is disabled."
  value       = local.cloud == "gcp" && var.enable_transit_firenet ? aviatrix_vpc.lan_vpc[0] : null
}

output "transit_group" {
  description = "The transit group object."
  value       = aviatrix_transit_group.default
}

output "transit_instances" {
  description = "Map of all transit instance objects, keyed by gateway name."
  value       = aviatrix_transit_instance.this
}

output "first_instance_name" {
  description = "Name of the first transit instance (used for firenet and peering references)."
  value       = local.first_instance_name
}

# Firenet details for composing with the mc-firenet module
output "mc_firenet_details" {
  description = "Object with firenet integration details for composing with the mc-firenet module."
  value = {
    name                   = var.name
    cloud                  = local.cloud
    region                 = var.region
    vpc_id                 = var.use_existing_vpc ? var.vpc_id : aviatrix_vpc.default[0].vpc_id
    lan_vpc                = local.cloud == "gcp" && var.enable_transit_firenet ? aviatrix_vpc.lan_vpc[0] : null
    use_existing_vpc       = var.use_existing_vpc
    enable_firenet         = var.enable_firenet
    enable_transit_firenet = var.enable_transit_firenet
    first_instance_name    = local.first_instance_name
    instance_count         = length(var.instances)
  }
}
