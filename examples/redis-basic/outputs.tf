output "replication_group_id" {
  description = "ID of the Redis replication group."
  value       = module.elasticache.replication_group_ids["main"]
}

output "replication_group_primary_endpoint" {
  description = "Primary endpoint address of the Redis replication group."
  value       = module.elasticache.replication_group_primary_endpoint_addresses["main"]
}

output "parameter_group_name" {
  description = "Name of the created parameter group."
  value       = module.elasticache.parameter_group_names["redis71"]
}

output "subnet_group_name" {
  description = "Name of the created subnet group."
  value       = module.elasticache.subnet_group_names["main"]
}
