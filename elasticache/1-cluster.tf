# =============================================================================
# ElastiCache Clusters (Memcached + standalone)
# =============================================================================

resource "aws_elasticache_cluster" "this" {
  for_each = { for k, v in var.clusters : k => v if var.create }

  cluster_id = "${local.name_prefix}cache-${var.account_name}-${var.project_name}-${each.key}"

  engine         = each.value.engine
  engine_version = each.value.engine_version
  node_type      = each.value.node_type

  num_cache_nodes              = each.value.num_cache_nodes
  port                         = each.value.port
  az_mode                      = each.value.az_mode
  preferred_availability_zones = length(each.value.preferred_availability_zones) > 0 ? each.value.preferred_availability_zones : null

  parameter_group_name = each.value.parameter_group_name != null ? each.value.parameter_group_name : (
    each.value.parameter_group_key != null ? aws_elasticache_parameter_group.this[each.value.parameter_group_key].name : null
  )

  subnet_group_name = each.value.subnet_group_name != null ? each.value.subnet_group_name : (
    each.value.subnet_group_key != null ? aws_elasticache_subnet_group.this[each.value.subnet_group_key].name : null
  )

  security_group_ids = each.value.security_group_ids

  maintenance_window         = each.value.maintenance_window
  notification_topic_arn     = each.value.notification_topic_arn
  apply_immediately          = each.value.apply_immediately
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  transit_encryption_enabled = each.value.transit_encryption_enabled
  network_type               = each.value.network_type
  ip_discovery               = each.value.ip_discovery

  snapshot_retention_limit  = each.value.snapshot_retention_limit
  snapshot_window           = each.value.snapshot_window
  snapshot_name             = each.value.snapshot_name
  final_snapshot_identifier = each.value.final_snapshot_identifier

  tags = merge(var.tags, each.value.tags, {
    Name = "${local.name_prefix}cache-${var.account_name}-${var.project_name}-${each.key}"
  })
}
