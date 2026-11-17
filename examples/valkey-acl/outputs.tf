output "replication_group_id" {
  description = "ID of the Valkey replication group."
  value       = module.elasticache.replication_group_ids["main"]
}

output "replication_group_primary_endpoint" {
  description = "Primary endpoint address of the Valkey replication group."
  value       = module.elasticache.replication_group_primary_endpoint_addresses["main"]
}

output "replication_group_reader_endpoint" {
  description = "Reader endpoint address of the Valkey replication group."
  value       = module.elasticache.replication_group_reader_endpoint_addresses["main"]
}

output "replica_cluster_id" {
  description = "ID of the additional read replica cluster."
  value       = module.elasticache.cluster_ids["replica"]
}

output "user_group_id" {
  description = "ID of the ACL user group."
  value       = module.elasticache.user_group_ids["main"]
}

output "user_ids" {
  description = "Map of ACL user keys to user IDs."
  value       = module.elasticache.user_ids
}
