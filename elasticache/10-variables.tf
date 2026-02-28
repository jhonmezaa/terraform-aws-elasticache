# =============================================================================
# General Configuration Variables
# =============================================================================

variable "create" {
  description = "Whether to create ElastiCache resources."
  type        = bool
  default     = true
}

variable "account_name" {
  description = "Account name for resource naming (e.g., 'prod', 'staging', 'dev')."
  type        = string

  validation {
    condition     = length(var.account_name) > 0 && length(var.account_name) <= 32
    error_message = "account_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from current region."
  type        = string
  default     = null
}

variable "use_region_prefix" {
  description = "Whether to include the region prefix in resource names."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Replication Groups (Redis)
# =============================================================================

variable "replication_groups" {
  description = "Map of Redis replication groups to create. This is the primary use case for Redis with HA."
  type = map(object({
    description                 = optional(string)
    engine                      = optional(string, "redis")
    engine_version              = optional(string, "7.1")
    node_type                   = string
    num_cache_clusters          = optional(number)
    num_node_groups             = optional(number)
    replicas_per_node_group     = optional(number)
    port                        = optional(number, 6379)
    parameter_group_name        = optional(string)
    parameter_group_key         = optional(string)
    subnet_group_name           = optional(string)
    subnet_group_key            = optional(string)
    security_group_ids          = optional(list(string), [])
    automatic_failover_enabled  = optional(bool, true)
    multi_az_enabled            = optional(bool, false)
    at_rest_encryption_enabled  = optional(bool, true)
    transit_encryption_enabled  = optional(bool, true)
    transit_encryption_mode     = optional(string)
    kms_key_id                  = optional(string)
    auth_token                  = optional(string)
    auth_token_update_strategy  = optional(string)
    user_group_ids              = optional(list(string), [])
    user_group_key              = optional(string)
    maintenance_window          = optional(string)
    snapshot_window             = optional(string)
    snapshot_retention_limit    = optional(number, 7)
    snapshot_arns               = optional(list(string), [])
    snapshot_name               = optional(string)
    final_snapshot_identifier   = optional(string)
    auto_minor_version_upgrade  = optional(bool, true)
    apply_immediately           = optional(bool, false)
    notification_topic_arn      = optional(string)
    preferred_cache_cluster_azs = optional(list(string), [])
    cluster_mode                = optional(string)
    data_tiering_enabled        = optional(bool, false)
    network_type                = optional(string)
    ip_discovery                = optional(string)
    log_delivery_configuration = optional(list(object({
      destination      = string
      destination_type = string
      log_format       = optional(string, "json")
      log_type         = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Clusters (Memcached)
# =============================================================================

variable "clusters" {
  description = "Map of ElastiCache clusters to create (primarily for Memcached)."
  type = map(object({
    engine                       = optional(string, "memcached")
    engine_version               = optional(string)
    node_type                    = string
    num_cache_nodes              = optional(number, 1)
    port                         = optional(number, 11211)
    az_mode                      = optional(string)
    preferred_availability_zones = optional(list(string), [])
    parameter_group_name         = optional(string)
    parameter_group_key          = optional(string)
    subnet_group_name            = optional(string)
    subnet_group_key             = optional(string)
    security_group_ids           = optional(list(string), [])
    maintenance_window           = optional(string)
    notification_topic_arn       = optional(string)
    apply_immediately            = optional(bool, false)
    auto_minor_version_upgrade   = optional(bool, true)
    transit_encryption_enabled   = optional(bool)
    network_type                 = optional(string)
    ip_discovery                 = optional(string)
    snapshot_retention_limit     = optional(number)
    snapshot_window              = optional(string)
    snapshot_name                = optional(string)
    final_snapshot_identifier    = optional(string)
    tags                         = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Serverless Caches
# =============================================================================

variable "serverless_caches" {
  description = "Map of ElastiCache serverless caches to create."
  type = map(object({
    engine                   = optional(string, "redis")
    major_engine_version     = optional(string, "7")
    description              = optional(string)
    daily_snapshot_time      = optional(string)
    kms_key_id               = optional(string)
    security_group_ids       = optional(list(string), [])
    subnet_ids               = optional(list(string), [])
    user_group_id            = optional(string)
    user_group_key           = optional(string)
    snapshot_arns_to_restore = optional(list(string))
    snapshot_retention_limit = optional(number)
    cache_usage_limits = optional(object({
      data_storage = optional(object({
        maximum = optional(number)
        minimum = optional(number)
        unit    = optional(string, "GB")
      }))
      ecpu_per_second = optional(object({
        maximum = optional(number)
        minimum = optional(number)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Subnet Groups
# =============================================================================

variable "subnet_groups" {
  description = "Map of ElastiCache subnet groups to create."
  type = map(object({
    subnet_ids  = list(string)
    description = optional(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Parameter Groups
# =============================================================================

variable "parameter_groups" {
  description = "Map of ElastiCache parameter groups to create."
  type = map(object({
    family      = string
    description = optional(string)
    parameters = optional(list(object({
      name  = string
      value = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Users (Redis ACL)
# =============================================================================

variable "users" {
  description = "Map of ElastiCache users to create for Redis ACL."
  type = map(object({
    user_id              = optional(string)
    user_name            = optional(string)
    access_string        = string
    engine               = optional(string, "redis")
    no_password_required = optional(bool)
    passwords            = optional(list(string))
    authentication_mode = optional(object({
      type      = string
      passwords = optional(list(string))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# User Groups (Redis ACL)
# =============================================================================

variable "user_groups" {
  description = "Map of ElastiCache user groups to create for Redis ACL."
  type = map(object({
    engine    = optional(string, "redis")
    user_ids  = optional(list(string), [])
    user_keys = optional(list(string), [])
    tags      = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Global Replication Groups
# =============================================================================

variable "global_replication_groups" {
  description = "Map of ElastiCache global replication groups to create."
  type = map(object({
    global_replication_group_description = optional(string)
    primary_replication_group_key        = string
    automatic_failover_enabled           = optional(bool, true)
    cache_node_type                      = optional(string)
    engine_version                       = optional(string)
    parameter_group_name                 = optional(string)
    num_node_groups                      = optional(number)
  }))
  default = {}
}
