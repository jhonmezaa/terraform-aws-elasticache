output "serverless_cache_name" {
  description = "Name of the serverless cache."
  value       = module.elasticache.serverless_cache_names["main"]
}

output "serverless_cache_arn" {
  description = "ARN of the serverless cache."
  value       = module.elasticache.serverless_cache_arns["main"]
}

output "serverless_cache_endpoint" {
  description = "Endpoint of the serverless cache."
  value       = module.elasticache.serverless_cache_endpoints["main"]
}

output "serverless_cache_reader_endpoint" {
  description = "Reader endpoint of the serverless cache."
  value       = module.elasticache.serverless_cache_reader_endpoints["main"]
}
