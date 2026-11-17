# =============================================================================
# ElastiCache Clusters (Memcached, standalone Redis/Valkey, RG read replicas)
# =============================================================================

locals {
  # A cluster that joins a replication group inherits engine, node type,
  # parameter/subnet/security groups, port, snapshots, etc. from the group,
  # so those arguments must be null (provider conflicts).
  cluster_in_replication_group = {
    for k, v in var.clusters : k => v.replication_group_id != null || v.replication_group_key != null
  }
}

resource "aws_elasticache_cluster" "this" {
  for_each = { for k, v in var.clusters : k => v if var.create }

  cluster_id = local.cluster_names[each.key]

  replication_group_id = each.value.replication_group_id != null ? each.value.replication_group_id : (
    each.value.replication_group_key != null ? aws_elasticache_replication_group.this[each.value.replication_group_key].id : null
  )

  engine         = local.cluster_in_replication_group[each.key] ? null : each.value.engine
  engine_version = local.cluster_in_replication_group[each.key] ? null : each.value.engine_version
  node_type      = local.cluster_in_replication_group[each.key] ? null : each.value.node_type

  num_cache_nodes              = local.cluster_in_replication_group[each.key] ? null : each.value.num_cache_nodes
  port                         = local.cluster_in_replication_group[each.key] ? null : each.value.port
  az_mode                      = local.cluster_in_replication_group[each.key] ? null : each.value.az_mode
  availability_zone            = each.value.availability_zone
  preferred_availability_zones = length(each.value.preferred_availability_zones) > 0 ? each.value.preferred_availability_zones : null
  outpost_mode                 = each.value.outpost_mode
  preferred_outpost_arn        = each.value.preferred_outpost_arn

  parameter_group_name = local.cluster_in_replication_group[each.key] ? null : (
    each.value.parameter_group_name != null ? each.value.parameter_group_name : (
      each.value.parameter_group_key != null ? aws_elasticache_parameter_group.this[each.value.parameter_group_key].name : null
    )
  )

  subnet_group_name = local.cluster_in_replication_group[each.key] ? null : (
    each.value.subnet_group_name != null ? each.value.subnet_group_name : (
      each.value.subnet_group_key != null ? aws_elasticache_subnet_group.this[each.value.subnet_group_key].name : null
    )
  )

  security_group_ids = local.cluster_in_replication_group[each.key] ? null : each.value.security_group_ids

  maintenance_window         = local.cluster_in_replication_group[each.key] ? null : each.value.maintenance_window
  notification_topic_arn     = local.cluster_in_replication_group[each.key] ? null : each.value.notification_topic_arn
  apply_immediately          = each.value.apply_immediately
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  transit_encryption_enabled = each.value.transit_encryption_enabled
  network_type               = each.value.network_type
  ip_discovery               = each.value.ip_discovery

  snapshot_retention_limit  = local.cluster_in_replication_group[each.key] ? null : each.value.snapshot_retention_limit
  snapshot_window           = local.cluster_in_replication_group[each.key] ? null : each.value.snapshot_window
  snapshot_arns             = local.cluster_in_replication_group[each.key] || length(each.value.snapshot_arns) == 0 ? null : each.value.snapshot_arns
  snapshot_name             = local.cluster_in_replication_group[each.key] ? null : each.value.snapshot_name
  final_snapshot_identifier = each.value.final_snapshot_identifier

  # Log delivery (standalone Redis/Valkey only)
  dynamic "log_delivery_configuration" {
    for_each = each.value.engine != "memcached" && !local.cluster_in_replication_group[each.key] ? each.value.log_delivery_configuration : []

    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
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
    Name      = local.cluster_names[each.key]
    ManagedBy = "Terraform"
  })
}
