locals {
  # =============================================================================
  # Region Prefix Mapping
  # =============================================================================

  region_prefix_map = {
    # US Regions
    "us-east-1" = "ause1"
    "us-east-2" = "ause2"
    "us-west-1" = "ausw1"
    "us-west-2" = "ausw2"
    # EU Regions
    "eu-west-1"    = "euwe1"
    "eu-west-2"    = "euwe2"
    "eu-west-3"    = "euwe3"
    "eu-central-1" = "euce1"
    "eu-central-2" = "euce2"
    "eu-north-1"   = "euno1"
    "eu-south-1"   = "euso1"
    "eu-south-2"   = "euso2"
    # AP Regions
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "apso1"
    "ap-south-2"     = "apso2"
    "ap-southeast-5" = "apse5"
    "ap-southeast-6" = "apse6"
    "ap-southeast-7" = "apse7"
    "ap-east-1"      = "apea1"
    "ap-east-2"      = "apea2"
    # SA Regions
    "sa-east-1" = "saea1"
    # CA Regions
    "ca-central-1" = "cace1"
    "ca-west-1"    = "cawe1"
    # MX Regions
    "mx-central-1" = "mxce1"
    # ME Regions
    "me-south-1"   = "meso1"
    "me-central-1" = "mece1"
    # AF Regions
    "af-south-1" = "afso1"
    # IL Regions
    "il-central-1" = "ilce1"
  }

  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.region,
    data.aws_region.current.region
  )

  # Name prefix: includes region prefix with trailing dash, or empty string
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # Common tags (tags is kept as a deprecated alias of tags_common)
  tags_common = merge(var.tags_common, var.tags)

  # =============================================================================
  # Resource names
  # =============================================================================
  # An explicit `name` always wins. Generated names are truncated to the AWS
  # limits (cluster ID: 50, replication group ID / serverless cache name: 40)
  # and never end with a hyphen.

  cluster_names = {
    for k, v in var.clusters : k => coalesce(
      v.name,
      trimsuffix(substr("${local.name_prefix}cache-${var.account_name}-${var.project_name}-${k}", 0, 50), "-")
    )
  }

  replication_group_names = {
    for k, v in var.replication_groups : k => coalesce(
      v.name,
      trimsuffix(substr("${local.name_prefix}redis-${var.account_name}-${var.project_name}-${k}", 0, 40), "-")
    )
  }

  serverless_cache_names = {
    for k, v in var.serverless_caches : k => coalesce(
      v.name,
      trimsuffix(substr("${local.name_prefix}sc-${var.account_name}-${var.project_name}-${k}", 0, 40), "-")
    )
  }

  subnet_group_names = {
    for k, v in var.subnet_groups : k => coalesce(v.name, "${local.name_prefix}cache-subnet-${var.account_name}-${var.project_name}-${k}")
  }

  parameter_group_names = {
    for k, v in var.parameter_groups : k => coalesce(v.name, "${local.name_prefix}cache-pg-${var.account_name}-${var.project_name}-${k}")
  }

  user_group_names = {
    for k, v in var.user_groups : k => coalesce(v.name, "${local.name_prefix}cache-ug-${var.account_name}-${var.project_name}-${k}")
  }

  global_replication_group_suffixes = {
    for k, v in var.global_replication_groups : k => coalesce(v.name, "${local.name_prefix}redis-global-${var.account_name}-${var.project_name}-${k}")
  }
}
