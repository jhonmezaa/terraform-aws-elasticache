# =============================================================================
# ElastiCache Subnet Groups
# =============================================================================

resource "aws_elasticache_subnet_group" "this" {
  for_each = { for k, v in var.subnet_groups : k => v if var.create }

  name        = local.subnet_group_names[each.key]
  description = coalesce(each.value.description, "ElastiCache subnet group for ${each.key}")
  subnet_ids  = each.value.subnet_ids

  tags = merge(local.tags_common, each.value.tags, {
    Name      = local.subnet_group_names[each.key]
    ManagedBy = "Terraform"
  })
}
