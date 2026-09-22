###############################################################################
# Transit VPC (conditional)
###############################################################################
resource "aviatrix_vpc" "default" {
  count                = var.use_existing_vpc ? 0 : 1
  cloud_type           = local.cloud_type
  region               = local.cloud == "gcp" ? null : var.region
  cidr                 = local.cloud == "gcp" ? null : var.cidr
  account_name         = var.account
  name                 = var.name
  aviatrix_transit_vpc = local.aviatrix_transit_vpc
  aviatrix_firenet_vpc = local.aviatrix_firenet_vpc
  resource_group      = var.resource_group
  enable_ipv6         = var.enable_ipv6
  vpc_ipv6_cidr       = var.ipv6_cidr

  dynamic "subnets" {
    for_each = local.cloud == "gcp" ? ["dummy"] : []
    content {
      name   = var.name
      cidr   = var.cidr
      region = var.region
    }
  }
}

###############################################################################
# GCP LAN VPC for Transit FireNet (conditional)
###############################################################################
resource "aviatrix_vpc" "lan_vpc" {
  count        = local.cloud == "gcp" && var.enable_transit_firenet ? 1 : 0
  cloud_type   = local.cloud_type
  account_name = var.account
  name         = "${var.name}-lan"

  dynamic "subnets" {
    for_each = ["dummy"]
    content {
      name   = "${var.name}-lan"
      cidr   = var.lan_cidr
      region = var.region
    }
  }
}

###############################################################################
# Transit Group
###############################################################################
resource "aviatrix_transit_group" "default" {
  group_name          = var.name
  cloud_type          = local.cloud_type
  gw_type             = var.gw_type
  group_instance_size = local.instance_size
  vpc_id              = var.use_existing_vpc ? var.vpc_id : aviatrix_vpc.default[0].vpc_id
  account_name        = var.account
  vpc_region          = length(var.region) > 0 ? var.region : null

  # Optional Network
  private_network = var.private_network

  # Optional Feature Flags
  enable_nat              = var.enable_nat
  enable_jumbo_frame      = var.enable_jumbo_frame
  enable_ipv6             = var.enable_ipv6
  enable_gro_gso          = var.enable_gro_gso
  enable_vpc_dns_server   = var.enable_vpc_dns_server
  enable_s2c_rx_balancing = var.enable_s2c_rx_balancing

  # Optional Transit-Specific
  enable_hybrid_connection             = var.enable_hybrid_connection
  enable_connected_transit             = var.enable_connected_transit
  enable_firenet                       = var.enable_firenet
  enable_transit_firenet               = var.enable_transit_firenet
  enable_advertise_transit_cidr        = var.enable_advertise_transit_cidr
  customized_spoke_vpc_routes          = var.customized_spoke_vpc_routes
  enable_transit_summarize_cidr_to_tgw = var.enable_transit_summarize_cidr_to_tgw
  enable_multi_tier_transit            = var.enable_multi_tier_transit
  enable_segmentation                  = var.enable_segmentation
  enable_gateway_load_balancer         = var.enable_gateway_load_balancer

  # Optional Azure
  private_route_table_config = length(var.private_route_table_config) > 0 ? var.private_route_table_config : null

  # Optional BGP
  local_as_number         = var.local_as_number
  prepend_as_path         = var.prepend_as_path
  enable_preserve_as_path = var.enable_preserve_as_path
  enable_bgp_ecmp         = var.enable_bgp_ecmp

  # Optional BGP Timers
  bgp_polling_time                 = var.bgp_polling_time
  bgp_neighbor_status_polling_time = var.bgp_neighbor_status_polling_time
  bgp_hold_time                    = var.bgp_hold_time

  # Optional BGP Communities
  bgp_send_communities   = var.bgp_send_communities
  bgp_accept_communities = var.bgp_accept_communities

  # Optional Learned CIDR
  enable_learned_cidrs_approval = var.enable_learned_cidrs_approval
  learned_cidrs_approval_mode   = var.learned_cidrs_approval_mode
  approved_learned_cidrs        = var.approved_learned_cidrs

  # Optional Active-Standby
  enable_active_standby            = var.enable_active_standby
  enable_active_standby_preemptive = var.enable_active_standby_preemptive

  # Optional GCP
  enable_global_vpc = var.enable_global_vpc
}

###############################################################################
# Transit Instances
###############################################################################
resource "aviatrix_transit_instance" "this" {
  for_each = var.instances

  # Required
  group_uuid = aviatrix_transit_group.default.group_uuid
  gw_size    = coalesce(each.value.gw_size, local.instance_size)

  # Basic
  gw_name = each.key
  subnet = each.value.subnet != null ? each.value.subnet : (
    var.use_existing_vpc ? null : (
      local.cloud == "gcp"
      ? aviatrix_vpc.default[0].subnets[index(keys(var.instances), each.key) % length(aviatrix_vpc.default[0].subnets)].cidr
      : aviatrix_vpc.default[0].public_subnets[index(keys(var.instances), each.key) % length(aviatrix_vpc.default[0].public_subnets)].cidr
    )
  )
  allocate_new_eip = each.value.allocate_new_eip
  eip              = each.value.eip
  single_az_ha     = each.value.single_az_ha
  tags             = each.value.tags != null ? merge(coalesce(var.tags, {}), each.value.tags) : var.tags

  # Module-level defaults with per-instance override
  tunnel_detection_time = each.value.tunnel_detection_time != null ? each.value.tunnel_detection_time : var.tunnel_detection_time

  # Route
  filtered_spoke_vpc_routes        = each.value.filtered_spoke_vpc_routes
  excluded_advertised_spoke_routes = each.value.excluded_advertised_spoke_routes
  customized_transit_vpc_routes    = each.value.customized_transit_vpc_routes
  bgp_manual_spoke_advertise_cidrs = each.value.bgp_manual_spoke_advertise_cidrs

  # Features — GCP FireNet LAN auto-populate
  lan_vpc_id = each.value.lan_vpc_id != null ? each.value.lan_vpc_id : (
    local.cloud == "gcp" && var.enable_transit_firenet ? aviatrix_vpc.lan_vpc[0].vpc_id : null
  )
  lan_private_subnet = each.value.lan_private_subnet != null ? each.value.lan_private_subnet : (
    local.cloud == "gcp" && var.enable_transit_firenet ? aviatrix_vpc.lan_vpc[0].subnets[0].cidr : null
  )
  enable_bgp_over_lan      = each.value.enable_bgp_over_lan
  bgp_lan_interfaces_count = each.value.bgp_lan_interfaces_count

  # Spot
  enable_spot_instance = each.value.enable_spot_instance
  spot_price           = each.value.spot_price
  delete_spot          = each.value.delete_spot

  # AWS-specific
  insane_mode                    = each.value.insane_mode != null ? each.value.insane_mode : var.insane_mode
  insane_mode_az                 = each.value.insane_mode_az
  rx_queue_size                  = each.value.rx_queue_size != null ? each.value.rx_queue_size : var.rx_queue_size
  enable_monitor_gateway_subnets = each.value.enable_monitor_gateway_subnets
  monitor_exclude_list           = each.value.monitor_exclude_list

  # Azure-specific
  zone                          = each.value.zone
  azure_eip_name_resource_group = each.value.azure_eip_name_resource_group

  # OCI-specific
  availability_domain = each.value.availability_domain
  fault_domain        = each.value.fault_domain

  # Private network
  private_subnet_egress_target = each.value.private_subnet_egress_target

  # Edge: interfaces
  dynamic "interfaces" {
    for_each = each.value.interfaces != null ? each.value.interfaces : []
    content {
      logical_ifname              = interfaces.value.logical_ifname
      ip_address                  = interfaces.value.ip_address
      gateway_ip                  = interfaces.value.gateway_ip
      public_ip                   = interfaces.value.public_ip
      dhcp                        = interfaces.value.dhcp
      secondary_private_cidr_list = interfaces.value.secondary_private_cidr_list
      underlay_cidr               = interfaces.value.underlay_cidr
    }
  }

  # Edge: interface_mapping
  dynamic "interface_mapping" {
    for_each = each.value.interface_mapping != null ? each.value.interface_mapping : []
    content {
      name  = interface_mapping.value.name
      type  = interface_mapping.value.type
      index = interface_mapping.value.index
    }
  }

  # Edge: other
  ztp_file_download_path     = each.value.ztp_file_download_path
  ztp_file_type              = each.value.ztp_file_type
  device_id                  = each.value.device_id
  peer_connection_type       = each.value.peer_connection_type
  peer_backup_logical_ifname = each.value.peer_backup_logical_ifname
  dynamic "eip_map" {
    for_each = each.value.eip_map != null ? each.value.eip_map : []
    content {
      logical_ifname = eip_map.value.logical_ifname
      private_ip     = eip_map.value.private_ip
      public_ip      = eip_map.value.public_ip
    }
  }
  management_egress_ip_prefix_list = each.value.management_egress_ip_prefix_list
}
