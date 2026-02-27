# =============================================================================
# Redis Basic - Single Node Replication Group
# =============================================================================
# This example creates a basic Redis replication group with:
# - Single node (no replicas)
# - Custom parameter group
# - Subnet group
# - At-rest and in-transit encryption
# =============================================================================

module "elasticache" {
  source = "../../elasticache"

  account_name = var.account_name
  project_name = var.project_name

  # Subnet Group
  subnet_groups = {
    main = {
      subnet_ids  = var.private_subnet_ids
      description = "Subnet group for Redis basic example"
    }
  }

  # Parameter Group
  parameter_groups = {
    redis71 = {
      family      = "redis7"
      description = "Parameter group for Redis 7.1"
      parameters = [
        {
          name  = "maxmemory-policy"
          value = "allkeys-lru"
        }
      ]
    }
  }

  # Redis Replication Group
  replication_groups = {
    main = {
      description    = "Basic Redis replication group"
      engine_version = "7.1"
      node_type      = "cache.t4g.micro"

      num_cache_clusters         = 1
      automatic_failover_enabled = false

      parameter_group_key = "redis71"
      subnet_group_key    = "main"
      security_group_ids  = var.security_group_ids

      at_rest_encryption_enabled = true
      transit_encryption_enabled = true

      maintenance_window       = "sun:05:00-sun:09:00"
      snapshot_window          = "03:00-04:00"
      snapshot_retention_limit = 7

      apply_immediately = true
    }
  }

  tags = {
    Environment = var.account_name
    Project     = var.project_name
    Example     = "redis-basic"
  }
}
