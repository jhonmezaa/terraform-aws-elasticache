# =============================================================================
# ElastiCache Parameter Groups
# =============================================================================

resource "aws_elasticache_parameter_group" "this" {
  for_each = { for k, v in var.parameter_groups : k => v if var.create }

  name        = "${local.name_prefix}cache-pg-${var.account_name}-${var.project_name}-${each.key}"
  family      = each.value.family
  description = coalesce(each.value.description, "ElastiCache parameter group for ${each.key}")

  dynamic "parameter" {
    for_each = each.value.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, each.value.tags, {
    Name = "${local.name_prefix}cache-pg-${var.account_name}-${var.project_name}-${each.key}"
  })

  lifecycle {
    create_before_destroy = true
  }
}
