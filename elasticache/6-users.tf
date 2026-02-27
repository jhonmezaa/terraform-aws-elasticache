# =============================================================================
# ElastiCache Users (Redis ACL)
# =============================================================================

resource "aws_elasticache_user" "this" {
  for_each = { for k, v in var.users : k => v if var.create }

  user_id   = coalesce(each.value.user_id, each.key)
  user_name = coalesce(each.value.user_name, each.key)

  access_string        = each.value.access_string
  engine               = each.value.engine
  no_password_required = each.value.no_password_required
  passwords            = each.value.passwords

  dynamic "authentication_mode" {
    for_each = each.value.authentication_mode != null ? [each.value.authentication_mode] : []

    content {
      type      = authentication_mode.value.type
      passwords = authentication_mode.value.passwords
    }
  }

  tags = merge(var.tags, each.value.tags, {
    Name = "${local.name_prefix}cache-user-${var.account_name}-${var.project_name}-${coalesce(each.value.user_id, each.key)}"
  })
}

# =============================================================================
# ElastiCache User Groups (Redis ACL)
# =============================================================================

resource "aws_elasticache_user_group" "this" {
  for_each = { for k, v in var.user_groups : k => v if var.create }

  user_group_id = "${local.name_prefix}cache-ug-${var.account_name}-${var.project_name}-${each.key}"
  engine        = each.value.engine

  user_ids = concat(
    each.value.user_ids,
    [for uk in each.value.user_keys : aws_elasticache_user.this[uk].user_id]
  )

  tags = merge(var.tags, each.value.tags, {
    Name = "${local.name_prefix}cache-ug-${var.account_name}-${var.project_name}-${each.key}"
  })

  lifecycle {
    ignore_changes = [user_ids]
  }
}
