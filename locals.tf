locals {
  ###############################################################################
  # Cloud normalization
  ###############################################################################
  cloud = lower(var.cloud)

  ###############################################################################
  # Cloud type mapping (including gov/china variants)
  ###############################################################################
  cloud_type_map = {
    aws   = 1
    gcp   = 4
    azure = 8
    oci   = 16
    ali   = 8192
  }

  cloud_type_map_china = {
    aws   = 1024
    azure = 2048
  }

  cloud_type_map_gov = {
    aws   = 256
    azure = 32
  }

  is_china = can(regex("^cn-|^china ", lower(var.region))) && contains(["aws", "azure"], local.cloud)
  is_gov   = can(regex("^us-gov|^usgov |^usdod ", lower(var.region))) && contains(["aws", "azure"], local.cloud)

  cloud_type = (
    local.is_china ? lookup(local.cloud_type_map_china, local.cloud, null) :
    local.is_gov ? lookup(local.cloud_type_map_gov, local.cloud, null) :
    lookup(local.cloud_type_map, local.cloud, null)
  )

  ###############################################################################
  # Instance size defaults per cloud (transit defaults are larger than spoke)
  ###############################################################################
  instance_size_map = {
    aws   = "c5.xlarge"
    gcp   = "n1-standard-1"
    azure = "Standard_D8s_v3"
    oci   = "VM.Standard2.2"
    ali   = "ecs.g5ne.large"
  }

  instance_size = length(var.instance_size) > 0 ? var.instance_size : lookup(local.instance_size_map, local.cloud, "")

  ###############################################################################
  # VPC subnet pair / size defaults
  ###############################################################################
  subnet_pairs_map = {
    aws   = 2
    azure = 2
  }

  subnet_size_map = {
    aws   = 28
    azure = 28
  }

  subnet_pairs = var.subnet_pairs != null ? var.subnet_pairs : lookup(local.subnet_pairs_map, local.cloud, null)
  subnet_size  = var.subnet_size != null ? var.subnet_size : lookup(local.subnet_size_map, local.cloud, null)

  ###############################################################################
  # VPC type flags for transit
  ###############################################################################
  aviatrix_transit_vpc = !var.enable_firenet && !var.enable_transit_firenet
  aviatrix_firenet_vpc = var.enable_firenet || var.enable_transit_firenet

  ###############################################################################
  # First instance name (used for firenet detail references)
  ###############################################################################
  first_instance_name = length(var.instances) > 0 ? keys(var.instances)[0] : ""
}
