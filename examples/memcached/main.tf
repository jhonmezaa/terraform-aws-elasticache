# =============================================================================
# Memcached Cluster
# =============================================================================
# This example creates a Memcached cluster with:
# - 3 cache nodes across AZs
# - Custom parameter group
# - Subnet group
# =============================================================================

module "elasticache" {
  source = "../../elasticache"

  account_name = var.account_name
  project_name = var.project_name

  # Subnet Group
  subnet_groups = {
    main = {
      subnet_ids  = var.private_subnet_ids
      description = "Subnet group for Memcached example"
    }
  }

  # Parameter Group
  parameter_groups = {
    memcached16 = {
      family      = "memcached1.6"
      description = "Parameter group for Memcached 1.6"
      parameters = [
        {
          name  = "max_item_size"
          value = "10485760"
        }
      ]
    }
  }

  # Memcached Cluster
  clusters = {
    main = {
      engine         = "memcached"
      engine_version = "1.6.22"
      node_type      = "cache.t4g.micro"

      num_cache_nodes = 3
      az_mode         = "cross-az"

      parameter_group_key = "memcached16"
      subnet_group_key    = "main"
      security_group_ids  = var.security_group_ids

      maintenance_window = "sun:05:00-sun:09:00"
      apply_immediately  = true
    }
  }

  tags = {
    Environment = var.account_name
    Project     = var.project_name
    Example     = "memcached"
  }
}
