# =============================================================================
# Redis Cluster Mode - Multi-shard with replicas
# =============================================================================
# This example creates a Redis cluster mode replication group with:
# - 3 shards (num_node_groups)
# - 2 replicas per shard
# - Multi-AZ enabled
# - Automatic failover
# - Custom parameter group with cluster-enabled
# - Log delivery to CloudWatch
# =============================================================================

module "elasticache" {
  source = "../../elasticache"

  account_name = var.account_name
  project_name = var.project_name

  # Subnet Group
  subnet_groups = {
    main = {
      subnet_ids  = var.private_subnet_ids
      description = "Subnet group for Redis cluster mode example"
    }
  }

  # Parameter Group (cluster-enabled)
  parameter_groups = {
    redis71-cluster = {
      family      = "redis7"
      description = "Parameter group for Redis 7.1 cluster mode"
      parameters = [
        {
          name  = "cluster-enabled"
          value = "yes"
        },
        {
          name  = "maxmemory-policy"
          value = "volatile-lru"
        }
      ]
    }
  }

  # Redis Replication Group with Cluster Mode
  replication_groups = {
    main = {
      description    = "Redis cluster mode replication group"
      engine_version = "7.1"
      node_type      = "cache.r7g.large"

      # Cluster mode settings
      num_node_groups         = 3
      replicas_per_node_group = 2

      parameter_group_key = "redis71-cluster"
      subnet_group_key    = "main"
      security_group_ids  = var.security_group_ids

      # HA
      automatic_failover_enabled = true
      multi_az_enabled           = true

      # Encryption
      at_rest_encryption_enabled = true
      transit_encryption_enabled = true
      transit_encryption_mode    = "required"

      # Maintenance
      maintenance_window       = "sun:05:00-sun:09:00"
      snapshot_window          = "03:00-04:00"
      snapshot_retention_limit = 14

      apply_immediately = true
    }
  }

  tags = {
    Environment = var.account_name
    Project     = var.project_name
    Example     = "redis-cluster"
  }
}
