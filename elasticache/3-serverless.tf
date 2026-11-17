# =============================================================================
# ElastiCache Serverless Caches
# =============================================================================

resource "aws_elasticache_serverless_cache" "this" {
  for_each = { for k, v in var.serverless_caches : k => v if var.create }

  name   = local.serverless_cache_names[each.key]
  engine = each.value.engine

  description          = coalesce(each.value.description, "Serverless cache for ${each.key}")
  major_engine_version = each.value.major_engine_version

  daily_snapshot_time      = each.value.daily_snapshot_time
  kms_key_id               = each.value.kms_key_id
  security_group_ids       = each.value.security_group_ids
  subnet_ids               = each.value.subnet_ids
  snapshot_arns_to_restore = each.value.snapshot_arns_to_restore
  snapshot_retention_limit = each.value.snapshot_retention_limit

  user_group_id = each.value.user_group_id != null ? each.value.user_group_id : (
    each.value.user_group_key != null ? aws_elasticache_user_group.this[each.value.user_group_key].user_group_id : null
  )

  dynamic "cache_usage_limits" {
    for_each = each.value.cache_usage_limits != null ? [each.value.cache_usage_limits] : []

    content {
      dynamic "data_storage" {
        for_each = cache_usage_limits.value.data_storage != null ? [cache_usage_limits.value.data_storage] : []

        content {
          maximum = data_storage.value.maximum
          minimum = data_storage.value.minimum
          unit    = data_storage.value.unit
        }
      }

      dynamic "ecpu_per_second" {
        for_each = cache_usage_limits.value.ecpu_per_second != null ? [cache_usage_limits.value.ecpu_per_second] : []

        content {
          maximum = ecpu_per_second.value.maximum
          minimum = ecpu_per_second.value.minimum
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(local.tags_common, each.value.tags, {
    Name      = local.serverless_cache_names[each.key]
    ManagedBy = "Terraform"
  })
}
