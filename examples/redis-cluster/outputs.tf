output "replication_group_id" {
  description = "ID of the Redis cluster mode replication group."
  value       = module.elasticache.replication_group_ids["main"]
}

output "replication_group_configuration_endpoint" {
  description = "Configuration endpoint address of the Redis cluster mode replication group."
  value       = module.elasticache.replication_group_configuration_endpoint_addresses["main"]
}

output "replication_group_member_clusters" {
  description = "Member clusters of the Redis cluster mode replication group."
  value       = module.elasticache.replication_groups["main"].member_clusters
}

output "parameter_group_name" {
  description = "Name of the created parameter group."
  value       = module.elasticache.parameter_group_names["redis71-cluster"]
}

output "subnet_group_name" {
  description = "Name of the created subnet group."
  value       = module.elasticache.subnet_group_names["main"]
}
