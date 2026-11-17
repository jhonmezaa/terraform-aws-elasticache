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
    error_message = "account_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name debe tener entre 1 y 32 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name solo puede contener letras minúsculas, números y guiones."
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

variable "tags_common" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "(Deprecated: use tags_common) Additional tags applied to all resources. Merged after tags_common."
  type        = map(string)
  default     = {}
}

# =============================================================================
# Replication Groups (Redis)
# =============================================================================

variable "replication_groups" {
  description = "Map of Redis/Valkey replication groups to create. This is the primary use case for Redis/Valkey with HA."
  type = map(object({
    name                        = optional(string)
    description                 = optional(string)
    engine                      = optional(string, "redis")
    engine_version              = optional(string, "7.1")
    node_type                   = optional(string)
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
    global_replication_group_id = optional(string)
    log_delivery_configuration = optional(list(object({
      destination      = string
      destination_type = string
      log_format       = optional(string, "json")
      log_type         = string
    })), [])
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.replication_groups : !(v.multi_az_enabled || v.automatic_failover_enabled) || v.num_node_groups != null || v.num_cache_clusters == null || try(v.num_cache_clusters >= 2, true)
    ])
    error_message = "automatic_failover_enabled/multi_az_enabled requieren num_cache_clusters >= 2 (o modo cluster con num_node_groups); con un solo nodo pon automatic_failover_enabled = false y multi_az_enabled = false."
  }

  validation {
    condition = alltrue([
      for k, v in var.replication_groups : v.node_type != null || v.global_replication_group_id != null
    ])
    error_message = "node_type es obligatorio en replication_groups salvo para miembros secundarios de un global datastore (global_replication_group_id)."
  }

  validation {
    condition = alltrue([
      for k, v in var.replication_groups : v.auth_token == null || v.transit_encryption_enabled || v.global_replication_group_id != null
    ])
    error_message = "auth_token requiere transit_encryption_enabled = true."
  }

  validation {
    condition = alltrue([
      for k, v in var.replication_groups : v.name == null || try(length(v.name) <= 40, false)
    ])
    error_message = "El name explícito de un replication group no puede superar 40 caracteres."
  }
}

# =============================================================================
# Clusters (Memcached)
# =============================================================================

variable "clusters" {
  description = "Map of ElastiCache clusters to create (Memcached, standalone Redis/Valkey, or read replicas attached to a replication group via replication_group_id/replication_group_key)."
  type = map(object({
    name                         = optional(string)
    replication_group_id         = optional(string)
    replication_group_key        = optional(string)
    engine                       = optional(string, "memcached")
    engine_version               = optional(string)
    node_type                    = optional(string)
    num_cache_nodes              = optional(number, 1)
    port                         = optional(number, 11211)
    az_mode                      = optional(string)
    availability_zone            = optional(string)
    preferred_availability_zones = optional(list(string), [])
    outpost_mode                 = optional(string)
    preferred_outpost_arn        = optional(string)
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
    snapshot_arns                = optional(list(string), [])
    snapshot_name                = optional(string)
    final_snapshot_identifier    = optional(string)
    log_delivery_configuration = optional(list(object({
      destination      = string
      destination_type = string
      log_format       = optional(string, "json")
      log_type         = string
    })), [])
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.clusters : v.node_type != null || v.replication_group_id != null || v.replication_group_key != null
    ])
    error_message = "node_type es obligatorio en clusters salvo para réplicas unidas a un replication group (replication_group_id/replication_group_key)."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : !(v.replication_group_id != null && v.replication_group_key != null)
    ])
    error_message = "En clusters, replication_group_id y replication_group_key son excluyentes."
  }

  validation {
    condition = alltrue([
      for k, v in var.clusters : v.name == null || try(length(v.name) <= 50, false)
    ])
    error_message = "El name explícito de un cluster no puede superar 50 caracteres."
  }
}

# =============================================================================
# Serverless Caches
# =============================================================================

variable "serverless_caches" {
  description = "Map of ElastiCache serverless caches to create."
  type = map(object({
    name                     = optional(string)
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
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.serverless_caches : v.name == null || try(length(v.name) <= 40, false)
    ])
    error_message = "El name explícito de una serverless cache no puede superar 40 caracteres."
  }
}

# =============================================================================
# Subnet Groups
# =============================================================================

variable "subnet_groups" {
  description = "Map of ElastiCache subnet groups to create."
  type = map(object({
    name        = optional(string)
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
    name        = optional(string)
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
    name      = optional(string)
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
    name                                 = optional(string)
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
