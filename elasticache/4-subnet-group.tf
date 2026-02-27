# =============================================================================
# ElastiCache Subnet Groups
# =============================================================================

resource "aws_elasticache_subnet_group" "this" {
  for_each = { for k, v in var.subnet_groups : k => v if var.create }

  name        = "${local.name_prefix}cache-subnet-${var.account_name}-${var.project_name}-${each.key}"
  description = coalesce(each.value.description, "ElastiCache subnet group for ${each.key}")
  subnet_ids  = each.value.subnet_ids

  tags = merge(var.tags, each.value.tags, {
    Name = "${local.name_prefix}cache-subnet-${var.account_name}-${var.project_name}-${each.key}"
  })
}
