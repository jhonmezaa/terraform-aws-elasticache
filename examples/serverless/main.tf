# =============================================================================
# Serverless Cache (Valkey)
# =============================================================================
# This example creates an ElastiCache serverless cache with:
# - Valkey 8 engine
# - Data storage and ECPU usage limits
# - Daily snapshots
# - Optional customer managed KMS key
# =============================================================================

module "elasticache" {
  source = "../../elasticache"

  account_name = var.account_name
  project_name = var.project_name

  serverless_caches = {
    main = {
      engine               = "valkey"
      major_engine_version = "8"
      description          = "Serverless Valkey cache example"

      subnet_ids         = var.private_subnet_ids
      security_group_ids = var.security_group_ids
      kms_key_id         = var.kms_key_arn

      cache_usage_limits = {
        data_storage = {
          maximum = 10
          unit    = "GB"
        }
        ecpu_per_second = {
          maximum = 5000
        }
      }

      daily_snapshot_time      = "03:00"
      snapshot_retention_limit = 7
    }
  }

  tags_common = {
    Environment = var.account_name
    Project     = var.project_name
    Example     = "serverless"
  }
}
