# =============================================================================
# ElastiCache Replication Groups (Redis)
# =============================================================================

resource "aws_elasticache_replication_group" "this" {
  for_each = { for k, v in var.replication_groups : k => v if var.create }

  replication_group_id = "${local.name_prefix}redis-${var.account_name}-${var.project_name}-${each.key}"
  description          = coalesce(each.value.description, "Redis replication group for ${each.key}")

  engine         = each.value.engine
  engine_version = each.value.engine_version
  node_type      = each.value.node_type

  # Non-cluster mode: num_cache_clusters
  num_cache_clusters = each.value.num_node_groups == null ? each.value.num_cache_clusters : null

  # Cluster mode: num_node_groups (shards) + replicas_per_node_group
  num_node_groups         = each.value.num_node_groups
  replicas_per_node_group = each.value.replicas_per_node_group
  cluster_mode            = each.value.cluster_mode

  port = each.value.port

  parameter_group_name = coalesce(
    each.value.parameter_group_name,
    each.value.parameter_group_key != null ? aws_elasticache_parameter_group.this[each.value.parameter_group_key].name : null
  )

  subnet_group_name = coalesce(
    each.value.subnet_group_name,
    each.value.subnet_group_key != null ? aws_elasticache_subnet_group.this[each.value.subnet_group_key].name : null
  )

  security_group_ids = each.value.security_group_ids

  # High Availability
  automatic_failover_enabled  = each.value.multi_az_enabled ? true : each.value.automatic_failover_enabled
  multi_az_enabled            = each.value.multi_az_enabled
  preferred_cache_cluster_azs = length(each.value.preferred_cache_cluster_azs) > 0 ? each.value.preferred_cache_cluster_azs : null

  # Encryption
  at_rest_encryption_enabled = each.value.at_rest_encryption_enabled
  transit_encryption_enabled = each.value.transit_encryption_enabled
  transit_encryption_mode    = each.value.transit_encryption_mode
  kms_key_id                 = each.value.at_rest_encryption_enabled ? each.value.kms_key_id : null

  # Auth
  auth_token                 = each.value.auth_token
  auth_token_update_strategy = each.value.auth_token_update_strategy

  user_group_ids = length(each.value.user_group_ids) > 0 ? each.value.user_group_ids : (
    each.value.user_group_key != null ? [aws_elasticache_user_group.this[each.value.user_group_key].user_group_id] : null
  )

  # Maintenance
  maintenance_window         = each.value.maintenance_window
  snapshot_window            = each.value.snapshot_window
  snapshot_retention_limit   = each.value.snapshot_retention_limit
  snapshot_arns              = length(each.value.snapshot_arns) > 0 ? each.value.snapshot_arns : null
  snapshot_name              = each.value.snapshot_name
  final_snapshot_identifier  = each.value.final_snapshot_identifier
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately

  # Notifications
  notification_topic_arn = each.value.notification_topic_arn

  # Data tiering (r6gd nodes)
  data_tiering_enabled = each.value.data_tiering_enabled

  # IP / Network
  network_type = each.value.network_type
  ip_discovery = each.value.ip_discovery

  # Log delivery
  dynamic "log_delivery_configuration" {
    for_each = each.value.log_delivery_configuration

    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = merge(var.tags, each.value.tags, {
    Name = "${local.name_prefix}redis-${var.account_name}-${var.project_name}-${each.key}"
  })
}
