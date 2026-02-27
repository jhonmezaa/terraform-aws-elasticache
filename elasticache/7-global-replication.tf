# =============================================================================
# ElastiCache Global Replication Groups
# =============================================================================

resource "aws_elasticache_global_replication_group" "this" {
  for_each = { for k, v in var.global_replication_groups : k => v if var.create }

  global_replication_group_id_suffix   = "${local.name_prefix}redis-global-${var.account_name}-${var.project_name}-${each.key}"
  global_replication_group_description = coalesce(each.value.global_replication_group_description, "Global replication group for ${each.key}")

  primary_replication_group_id = aws_elasticache_replication_group.this[each.value.primary_replication_group_key].id

  automatic_failover_enabled = each.value.automatic_failover_enabled
  cache_node_type            = each.value.cache_node_type
  engine_version             = each.value.engine_version
  parameter_group_name       = each.value.parameter_group_name
  num_node_groups            = each.value.num_node_groups
}
