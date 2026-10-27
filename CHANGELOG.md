# Changelog

All notable changes to this project will be documented in this file.

## [v1.0.7] - 2026-10-27

### Changed

- Docs: normalize CHANGELOG format (preamble moved to the top, `v`-prefixed version headers)
- Docs: add missing CHANGELOG entries for v1.0.1, v1.0.2 and v1.0.3

## [v1.0.6] - 2026-10-27

### Fixed

- Replace deprecated `data.aws_region.current.id` with `data.aws_region.current.region` (deprecated in AWS provider v6)

## [v1.0.5] - 2026-10-27

### Changed

- Use minimum-only version constraints in the reusable module: AWS provider `~> 6.0` -> `>= 6.0`
- Set module `required_version` to `>= 1.3` (was `~> 1.0`): the module uses `optional()` object type attributes, introduced in Terraform 1.3
- Example root modules keep pessimistic `~>` constraints (AWS provider `~> 6.0`, Terraform `~> 1.3`)
- Update requirements in README accordingly

## [v1.0.4] - 2026-04-25

### Changed

- Update README documentation and CHANGELOG formatting

## [v1.0.3] - 2026-02-28

### Changed

- Update README

## [v1.0.2] - 2026-02-28

### Fixed

- Replace `coalesce()` with conditional expressions for `parameter_group_name`, `subnet_group_name` and `user_group_id` cross-references in cluster, replication group and serverless resources (`coalesce()` errors when all arguments are null)
- Shorten serverless cache name prefix from `cache-` to `sc-` to stay within the AWS 40-character limit for serverless cache names

## [v1.0.1] - 2026-02-27

### Fixed

- Use lowercase `redis` as default engine for the `users` variable (AWS provider deprecated case-insensitive matching for `engine` in `aws_elasticache_user`)

## [v1.0.0] - 2026-02-27

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
