# Changelog


## [v1.0.4] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-02-27

### Added

- ElastiCache replication groups (Redis) with full HA support
  - Automatic failover, multi-AZ, cluster mode
  - At-rest and in-transit encryption
  - AUTH token and Redis ACL (user groups)
  - Log delivery configuration (CloudWatch, Kinesis Firehose)
  - Data tiering support (r6gd nodes)
  - IPv4/IPv6/dual-stack network support
- ElastiCache clusters (Memcached)
  - Single-AZ and cross-AZ modes
  - Configurable node count
- ElastiCache serverless caches
  - Cache usage limits (data storage, ECPU)
  - Daily snapshots
  - KMS encryption
- Subnet groups with for_each pattern
- Parameter groups with dynamic parameters
- Users and user groups (Redis ACL)
- Global replication groups for cross-region replication
- Consistent naming convention: `{region_prefix}-{resource-type}-{account_name}-{project_name}-{key}`
- Region prefix auto-detection for 29 AWS regions
- Three complete examples: redis-basic, redis-cluster, memcached
