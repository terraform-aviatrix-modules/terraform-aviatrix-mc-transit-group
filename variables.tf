###############################################################################
# VPC Configuration
###############################################################################

variable "cloud" {
  description = "Cloud type. Valid values: aws, azure, gcp, oci, ali."
  type        = string

  validation {
    condition     = contains(["aws", "azure", "gcp", "oci", "ali"], lower(var.cloud))
    error_message = "cloud must be one of: aws, azure, gcp, oci, ali."
  }
}

variable "name" {
  description = "Name for the VPC/VNet and transit group."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "name must be between 1 and 50 characters."
  }
}

variable "account" {
  description = "Aviatrix access account name."
  type        = string
}

variable "region" {
  description = "Region for the VPC/VNet. Optional for edge gateways."
  type        = string
  default     = ""
}

variable "cidr" {
  description = "CIDR block for the VPC/VNet. Not used for GCP or when use_existing_vpc is true."
  type        = string
  default     = ""
}

variable "use_existing_vpc" {
  description = "Set to true to use an existing VPC/VNet instead of creating one."
  type        = bool
  default     = false
  nullable    = false
}

variable "vpc_id" {
  description = "VPC ID when using an existing VPC (use_existing_vpc = true)."
  type        = string
  default     = ""
}

variable "resource_group" {
  description = "Azure resource group name. Only used for Azure."
  type        = string
  default     = null
}

variable "enable_ipv6" {
  description = "Enable IPv6 on the VPC and transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "ipv6_cidr" {
  description = "IPv6 CIDR for the VPC. Auto-assigned for AWS."
  type        = string
  default     = null
}

variable "lan_cidr" {
  description = "CIDR for the GCP LAN VPC used with Transit FireNet. Only used when cloud is GCP and enable_transit_firenet is true."
  type        = string
  default     = ""
}

###############################################################################
# Gateway Group Configuration
###############################################################################

variable "gw_type" {
  description = "Gateway type. Valid values: TRANSIT, EDGETRANSIT, STANDALONE."
  type        = string
  default     = "TRANSIT"

  validation {
    condition     = contains(["TRANSIT", "EDGETRANSIT", "STANDALONE"], var.gw_type)
    error_message = "gw_type must be one of: TRANSIT, EDGETRANSIT, STANDALONE."
  }
}

variable "instance_size" {
  description = "Gateway instance size. Defaults per cloud if empty (e.g. c5.xlarge for AWS)."
  type        = string
  default     = ""
}

# --- Optional Network ---

variable "private_network" {
  description = "Deploy gateways without a public IP. Gateways reach the controller via the subnet's existing egress path. Only supported for AWS and Azure."
  type        = bool
  default     = false
  nullable    = false
}

# --- Optional Feature Flags ---

variable "enable_nat" {
  description = "Enable NAT on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_jumbo_frame" {
  description = "Enable jumbo frame support on the transit group."
  type        = bool
  default     = null
}

variable "enable_gro_gso" {
  description = "Enable GRO/GSO on the transit group."
  type        = bool
  default     = null
}

variable "enable_vpc_dns_server" {
  description = "Enable VPC DNS server on the transit group."
  type        = bool
  default     = null
}

variable "enable_s2c_rx_balancing" {
  description = "Enable S2C RX balancing on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

# --- Optional Transit-Specific ---

variable "enable_hybrid_connection" {
  description = "Enable hybrid connection (TGW/DXGW/VGW) on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_connected_transit" {
  description = "Enable connected transit on the transit group."
  type        = bool
  default     = true
  nullable    = false
}

variable "enable_firenet" {
  description = "Enable FireNet on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_transit_firenet" {
  description = "Enable Transit FireNet on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_advertise_transit_cidr" {
  description = "Enable advertise transit CIDR on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "customized_spoke_vpc_routes" {
  description = "Set of customized spoke VPC routes for the transit group."
  type        = set(string)
  default     = null
}

variable "enable_transit_summarize_cidr_to_tgw" {
  description = "Enable transit summarize CIDR to TGW on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_multi_tier_transit" {
  description = "Enable multi-tier transit on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_segmentation" {
  description = "Enable segmentation on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_gateway_load_balancer" {
  description = "Enable Gateway Load Balancer on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

# --- Optional Azure ---

variable "private_route_table_config" {
  description = "List of private route table labels for the transit group (Azure)."
  type        = list(string)
  default     = []
  nullable    = false
}

# --- Optional BGP ---

variable "local_as_number" {
  description = "Local AS number for BGP."
  type        = string
  default     = null
}

variable "prepend_as_path" {
  description = "List of AS numbers to prepend to the AS path."
  type        = list(string)
  default     = null
}

variable "enable_preserve_as_path" {
  description = "Enable preserve AS path."
  type        = bool
  default     = null
}

variable "enable_bgp_ecmp" {
  description = "Enable BGP ECMP on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

# --- Optional BGP Timers ---

variable "bgp_polling_time" {
  description = "BGP route polling time in seconds."
  type        = number
  default     = null
}

variable "bgp_neighbor_status_polling_time" {
  description = "BGP neighbor status polling time in seconds."
  type        = number
  default     = null
}

variable "bgp_hold_time" {
  description = "BGP hold time in seconds."
  type        = number
  default     = null
}

# --- Optional BGP Communities ---

variable "bgp_send_communities" {
  description = "Enable sending BGP communities."
  type        = bool
  default     = null
}

variable "bgp_accept_communities" {
  description = "Enable accepting BGP communities."
  type        = bool
  default     = null
}

# --- Optional Learned CIDR ---

variable "enable_learned_cidrs_approval" {
  description = "Enable learned CIDRs approval."
  type        = bool
  default     = false
  nullable    = false
}

variable "learned_cidrs_approval_mode" {
  description = "Learned CIDRs approval mode. Valid values: gateway, connection."
  type        = string
  default     = null
}

variable "approved_learned_cidrs" {
  description = "Set of approved learned CIDRs."
  type        = set(string)
  default     = null
}

# --- Optional Active-Standby ---

variable "enable_active_standby" {
  description = "Enable active-standby mode on the transit group."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_active_standby_preemptive" {
  description = "Enable active-standby preemptive mode."
  type        = bool
  default     = null
}

# --- Optional GCP ---

variable "enable_global_vpc" {
  description = "Enable global VPC for GCP."
  type        = bool
  default     = null
}

###############################################################################
# Gateway Instances
###############################################################################

variable "instances" {
  description = "Map of transit gateway instances to create. Key is the gateway name. Use empty objects for default settings."
  type = map(object({
    subnet                           = optional(string)
    gw_size                          = optional(string)
    zone                             = optional(string)
    allocate_new_eip                 = optional(bool)
    eip                              = optional(string)
    single_az_ha                     = optional(bool)
    tags                             = optional(map(string))
    tunnel_detection_time            = optional(number)
    filtered_spoke_vpc_routes        = optional(string)
    excluded_advertised_spoke_routes = optional(string)
    customized_transit_vpc_routes    = optional(set(string))
    bgp_manual_spoke_advertise_cidrs = optional(string)
    lan_vpc_id                       = optional(string)
    lan_private_subnet               = optional(string)
    enable_bgp_over_lan              = optional(bool)
    bgp_lan_interfaces_count         = optional(number)
    enable_spot_instance             = optional(bool)
    spot_price                       = optional(string)
    delete_spot                      = optional(bool)
    insane_mode                      = optional(bool)
    insane_mode_az                   = optional(string)
    rx_queue_size                    = optional(string)
    enable_monitor_gateway_subnets   = optional(bool)
    monitor_exclude_list             = optional(set(string))
    azure_eip_name_resource_group    = optional(string)
    availability_domain              = optional(string)
    fault_domain                     = optional(string)
    interfaces = optional(list(object({
      logical_ifname              = string
      ip_address                  = optional(string)
      gateway_ip                  = optional(string)
      public_ip                   = optional(string)
      dhcp                        = optional(bool)
      secondary_private_cidr_list = optional(list(string))
      underlay_cidr               = optional(string)
    })))
    interface_mapping = optional(list(object({
      name  = string
      type  = string
      index = number
    })))
    ztp_file_download_path     = optional(string)
    ztp_file_type              = optional(string)
    device_id                  = optional(string)
    peer_connection_type       = optional(string)
    peer_backup_logical_ifname = optional(list(string))
    eip_map = optional(list(object({
      logical_ifname = string
      private_ip     = string
      public_ip      = string
    })))
    management_egress_ip_prefix_list = optional(list(string))
    private_subnet_egress_target     = optional(string)
  }))
  default = {}

}

variable "insane_mode" {
  description = "Module-level default for insane mode / High Performance Encryption (HPE). Can be overridden per instance."
  type        = bool
  default     = false
  nullable    = false
}

variable "tunnel_detection_time" {
  description = "Module-level default for tunnel detection time in seconds. Can be overridden per instance."
  type        = number
  default     = null
}

variable "rx_queue_size" {
  description = "Module-level default for rx queue size (AWS). Can be overridden per instance."
  type        = string
  default     = null
}

variable "tags" {
  description = "Module-level tags applied to all instances. Per-instance tags are merged on top."
  type        = map(string)
  default     = null
}
