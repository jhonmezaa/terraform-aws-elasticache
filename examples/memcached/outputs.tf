output "cluster_id" {
  description = "ID of the Memcached cluster."
  value       = module.elasticache.cluster_ids["main"]
}

output "cluster_address" {
  description = "DNS name of the Memcached cluster."
  value       = module.elasticache.cluster_addresses["main"]
}

output "cluster_configuration_endpoint" {
  description = "Configuration endpoint of the Memcached cluster."
  value       = module.elasticache.cluster_configuration_endpoints["main"]
}

output "parameter_group_name" {
  description = "Name of the created parameter group."
  value       = module.elasticache.parameter_group_names["memcached16"]
}

output "subnet_group_name" {
  description = "Name of the created subnet group."
  value       = module.elasticache.subnet_group_names["main"]
}
