# =============================================================================
# Valkey Replication Group with ACL users and a read replica cluster
# =============================================================================
# This example creates:
# - Valkey 8 replication group (primary + 1 replica, multi-AZ)
# - ACL users and a user group attached to the replication group
# - An additional read replica cluster attached to the replication group
#   (clusters.replication_group_key)
# =============================================================================

module "elasticache" {
  source = "../../elasticache"

  account_name = var.account_name
  project_name = var.project_name

  subnet_groups = {
    main = {
      subnet_ids  = var.private_subnet_ids
      description = "Subnet group for Valkey ACL example"
    }
  }

  parameter_groups = {
    valkey8 = {
      family      = "valkey8"
      description = "Parameter group for Valkey 8"
    }
  }

  # ACL users
  users = {
    default = {
      user_id       = "${var.project_name}-default"
      user_name     = "default"
      engine        = "valkey"
      access_string = "off -@all"
      authentication_mode = {
        type      = "password"
        passwords = [var.default_user_password]
      }
    }
    app = {
      user_id       = "${var.project_name}-app"
      user_name     = "app"
      engine        = "valkey"
      access_string = "on ~app:* +@all"
      authentication_mode = {
        type      = "password"
        passwords = [var.app_user_password]
      }
    }
  }

  user_groups = {
    main = {
      engine    = "valkey"
      user_keys = ["default", "app"]
    }
  }

  replication_groups = {
    main = {
      description    = "Valkey replication group with ACL"
      engine         = "valkey"
      engine_version = "8.0"
      node_type      = "cache.t4g.small"

      num_cache_clusters         = 2
      automatic_failover_enabled = true
      multi_az_enabled           = true

      parameter_group_key = "valkey8"
      subnet_group_key    = "main"
      security_group_ids  = var.security_group_ids
      user_group_key      = "main"

      at_rest_encryption_enabled = true
      transit_encryption_enabled = true

      maintenance_window = "sun:05:00-sun:09:00"
      snapshot_window    = "03:00-04:00"
    }
  }

  # Extra read replica attached to the replication group
  clusters = {
    replica = {
      # engine, node type, port, subnet/parameter/security groups are
      # inherited from the replication group
      replication_group_key = "main"
    }
  }

  tags_common = {
    Environment = var.account_name
    Project     = var.project_name
    Example     = "valkey-acl"
  }
}
