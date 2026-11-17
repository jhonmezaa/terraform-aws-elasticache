# =============================================================================
# ElastiCache Parameter Groups
# =============================================================================

resource "aws_elasticache_parameter_group" "this" {
  for_each = { for k, v in var.parameter_groups : k => v if var.create }

  name        = local.parameter_group_names[each.key]
  family      = each.value.family
  description = coalesce(each.value.description, "ElastiCache parameter group for ${each.key}")

  dynamic "parameter" {
    for_each = each.value.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(local.tags_common, each.value.tags, {
    Name      = local.parameter_group_names[each.key]
    ManagedBy = "Terraform"
  })

  lifecycle {
    create_before_destroy = true
  }
}
