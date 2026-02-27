# =============================================================================
# Replication Group Outputs
# =============================================================================

output "replication_groups" {
  description = "Map of all created ElastiCache replication groups and their attributes."
  value = {
    for k, v in aws_elasticache_replication_group.this : k => {
      id                             = v.id
      arn                            = v.arn
      engine_version_actual          = v.engine_version_actual
      primary_endpoint_address       = v.primary_endpoint_address
      reader_endpoint_address        = v.reader_endpoint_address
      configuration_endpoint_address = v.configuration_endpoint_address
      port                           = v.port
      member_clusters                = v.member_clusters
    }
  }
}

output "replication_group_ids" {
  description = "Map of replication group keys to their IDs."
  value       = { for k, v in aws_elasticache_replication_group.this : k => v.id }
}

output "replication_group_arns" {
  description = "Map of replication group keys to their ARNs."
  value       = { for k, v in aws_elasticache_replication_group.this : k => v.arn }
}

output "replication_group_primary_endpoint_addresses" {
  description = "Map of replication group keys to their primary endpoint addresses."
  value       = { for k, v in aws_elasticache_replication_group.this : k => v.primary_endpoint_address }
}

output "replication_group_reader_endpoint_addresses" {
  description = "Map of replication group keys to their reader endpoint addresses."
  value       = { for k, v in aws_elasticache_replication_group.this : k => v.reader_endpoint_address }
}

output "replication_group_configuration_endpoint_addresses" {
  description = "Map of replication group keys to their configuration endpoint addresses (cluster mode)."
  value       = { for k, v in aws_elasticache_replication_group.this : k => v.configuration_endpoint_address }
}

# =============================================================================
# Cluster Outputs
# =============================================================================

output "clusters" {
  description = "Map of all created ElastiCache clusters and their attributes."
  value = {
    for k, v in aws_elasticache_cluster.this : k => {
      id                     = v.id
      arn                    = v.arn
      engine_version_actual  = v.engine_version_actual
      cache_nodes            = v.cache_nodes
      cluster_address        = v.cluster_address
      configuration_endpoint = v.configuration_endpoint
    }
  }
}

output "cluster_ids" {
  description = "Map of cluster keys to their IDs."
  value       = { for k, v in aws_elasticache_cluster.this : k => v.id }
}

output "cluster_arns" {
  description = "Map of cluster keys to their ARNs."
  value       = { for k, v in aws_elasticache_cluster.this : k => v.arn }
}

output "cluster_addresses" {
  description = "Map of cluster keys to their cluster addresses (Memcached only)."
  value       = { for k, v in aws_elasticache_cluster.this : k => v.cluster_address }
}

output "cluster_configuration_endpoints" {
  description = "Map of cluster keys to their configuration endpoints (Memcached only)."
  value       = { for k, v in aws_elasticache_cluster.this : k => v.configuration_endpoint }
}

# =============================================================================
# Serverless Cache Outputs
# =============================================================================

output "serverless_caches" {
  description = "Map of all created ElastiCache serverless caches and their attributes."
  value = {
    for k, v in aws_elasticache_serverless_cache.this : k => {
      arn                  = v.arn
      name                 = v.name
      full_engine_version  = v.full_engine_version
      major_engine_version = v.major_engine_version
      status               = v.status
      endpoint             = v.endpoint
      reader_endpoint      = v.reader_endpoint
      create_time          = v.create_time
    }
  }
}

output "serverless_cache_arns" {
  description = "Map of serverless cache keys to their ARNs."
  value       = { for k, v in aws_elasticache_serverless_cache.this : k => v.arn }
}

output "serverless_cache_endpoints" {
  description = "Map of serverless cache keys to their endpoints."
  value       = { for k, v in aws_elasticache_serverless_cache.this : k => v.endpoint }
}

output "serverless_cache_reader_endpoints" {
  description = "Map of serverless cache keys to their reader endpoints."
  value       = { for k, v in aws_elasticache_serverless_cache.this : k => v.reader_endpoint }
}

# =============================================================================
# Subnet Group Outputs
# =============================================================================

output "subnet_group_names" {
  description = "Map of subnet group keys to their names."
  value       = { for k, v in aws_elasticache_subnet_group.this : k => v.name }
}

output "subnet_group_arns" {
  description = "Map of subnet group keys to their ARNs."
  value       = { for k, v in aws_elasticache_subnet_group.this : k => v.arn }
}

# =============================================================================
# Parameter Group Outputs
# =============================================================================

output "parameter_group_names" {
  description = "Map of parameter group keys to their names."
  value       = { for k, v in aws_elasticache_parameter_group.this : k => v.name }
}

output "parameter_group_ids" {
  description = "Map of parameter group keys to their IDs."
  value       = { for k, v in aws_elasticache_parameter_group.this : k => v.id }
}

output "parameter_group_arns" {
  description = "Map of parameter group keys to their ARNs."
  value       = { for k, v in aws_elasticache_parameter_group.this : k => v.arn }
}

# =============================================================================
# User Outputs
# =============================================================================

output "user_ids" {
  description = "Map of user keys to their user IDs."
  value       = { for k, v in aws_elasticache_user.this : k => v.user_id }
}

output "user_arns" {
  description = "Map of user keys to their ARNs."
  value       = { for k, v in aws_elasticache_user.this : k => v.arn }
}

# =============================================================================
# User Group Outputs
# =============================================================================

output "user_group_ids" {
  description = "Map of user group keys to their user group IDs."
  value       = { for k, v in aws_elasticache_user_group.this : k => v.user_group_id }
}

output "user_group_arns" {
  description = "Map of user group keys to their ARNs."
  value       = { for k, v in aws_elasticache_user_group.this : k => v.arn }
}

# =============================================================================
# Global Replication Group Outputs
# =============================================================================

output "global_replication_group_ids" {
  description = "Map of global replication group keys to their IDs."
  value       = { for k, v in aws_elasticache_global_replication_group.this : k => v.id }
}

output "global_replication_group_arns" {
  description = "Map of global replication group keys to their ARNs."
  value       = { for k, v in aws_elasticache_global_replication_group.this : k => v.arn }
}

output "global_replication_group_engine_version_actual" {
  description = "Map of global replication group keys to their actual engine versions."
  value       = { for k, v in aws_elasticache_global_replication_group.this : k => v.engine_version_actual }
}

output "global_replication_group_node_groups" {
  description = "Map of global replication group keys to their node groups."
  value       = { for k, v in aws_elasticache_global_replication_group.this : k => v.global_node_groups }
}
