# Terraform AWS ElastiCache Module

Terraform module for AWS ElastiCache: Redis/Valkey replication groups, Memcached and standalone clusters, read replica clusters, serverless caches, global datastores and all supporting resources.

## Features

- **Replication Groups (Redis/Valkey)** - Primary/replica with automatic failover, multi-AZ, cluster mode (sharding)
- **Clusters** - Memcached (single-AZ / cross-AZ), standalone Redis/Valkey, or read replicas attached to a replication group
- **Serverless Caches** - Redis, Valkey and Memcached with usage limits
- **Subnet Groups** - Network isolation for cache nodes
- **Parameter Groups** - Custom engine configuration
- **Users & User Groups** - Redis/Valkey ACL for fine-grained access control
- **Global Datastores** - Primary global replication group plus secondary members in other regions (`global_replication_group_id`)
- **Encryption** - At-rest (KMS) and in-transit (TLS) encryption, enabled by default on replication groups
- **Logging** - Slow/engine log delivery to CloudWatch Logs or Kinesis Firehose
- **Consistent Naming** - Region-aware naming convention across all resources, with per-resource `name` override

## Usage

### Redis Replication Group (Basic)

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache?ref=v1.1.0"

  account_name = "prod"
  project_name = "myapp"

  subnet_groups = {
    main = {
      subnet_ids = ["subnet-abc123", "subnet-def456"]
    }
  }

  parameter_groups = {
    redis71 = {
      family = "redis7"
      parameters = [
        { name = "maxmemory-policy", value = "allkeys-lru" }
      ]
    }
  }

  replication_groups = {
    main = {
      node_type          = "cache.t4g.micro"
      num_cache_clusters = 2

      parameter_group_key = "redis71"
      subnet_group_key    = "main"
      security_group_ids  = ["sg-0123456789abcdef0"]

      automatic_failover_enabled = true
      multi_az_enabled           = true
    }
  }

  tags_common = {
    Environment = "prod"
  }
}
```

### Redis Cluster Mode (Sharding)

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache?ref=v1.1.0"

  account_name = "prod"
  project_name = "myapp"

  subnet_groups = {
    main = { subnet_ids = var.private_subnet_ids }
  }

  parameter_groups = {
    redis71-cluster = {
      family = "redis7"
      parameters = [
        { name = "cluster-enabled", value = "yes" }
      ]
    }
  }

  replication_groups = {
    main = {
      node_type               = "cache.r7g.large"
      num_node_groups         = 3
      replicas_per_node_group = 2

      parameter_group_key        = "redis71-cluster"
      subnet_group_key           = "main"
      security_group_ids         = var.security_group_ids
      automatic_failover_enabled = true
      multi_az_enabled           = true
    }
  }
}
```

### Memcached Cluster

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache?ref=v1.1.0"

  account_name = "prod"
  project_name = "myapp"

  subnet_groups = {
    main = { subnet_ids = var.private_subnet_ids }
  }

  parameter_groups = {
    memcached16 = { family = "memcached1.6" }
  }

  clusters = {
    main = {
      engine          = "memcached"
      engine_version  = "1.6.22"
      node_type       = "cache.t4g.micro"
      num_cache_nodes = 3
      az_mode         = "cross-az"

      parameter_group_key = "memcached16"
      subnet_group_key    = "main"
      security_group_ids  = var.security_group_ids
    }
  }
}
```

### Read Replica Cluster attached to a Replication Group

A cluster with `replication_group_key` (or `replication_group_id`) joins the replication group and inherits its engine, node type, port, parameter/subnet/security groups and snapshot settings; the module sets those arguments to `null`.

```hcl
  clusters = {
    replica = {
      replication_group_key = "main"
    }
  }
```

### Serverless Cache

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache?ref=v1.1.0"

  account_name = "prod"
  project_name = "myapp"

  serverless_caches = {
    main = {
      engine               = "valkey"
      major_engine_version = "8"
      security_group_ids   = var.security_group_ids
      subnet_ids           = var.private_subnet_ids
      kms_key_id           = var.kms_key_arn

      cache_usage_limits = {
        data_storage    = { maximum = 5, unit = "GB" }
        ecpu_per_second = { maximum = 5000 }
      }

      snapshot_retention_limit = 7
      daily_snapshot_time      = "22:00"
    }
  }
}
```

### Global Datastore

Primary region: create the replication group and the global replication group in the same module call.

```hcl
module "elasticache_primary" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache?ref=v1.1.0"

  account_name = "prod"
  project_name = "myapp"

  replication_groups = {
    primary = {
      node_type          = "cache.r7g.large"
      num_cache_clusters = 2
      subnet_group_name  = "my-subnet-group"
    }
  }

  global_replication_groups = {
    main = {
      primary_replication_group_key = "primary"
    }
  }
}
```

Secondary region: a separate module call (with a provider for that region) and `global_replication_group_id`. Engine, engine version, node type, encryption, parameter group and shard count are inherited from the global datastore, so the module sets them to `null`.

```hcl
module "elasticache_secondary" {
  source    = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache?ref=v1.1.0"
  providers = { aws = aws.secondary }

  account_name = "prod"
  project_name = "myapp"

  replication_groups = {
    secondary = {
      global_replication_group_id = module.elasticache_primary.global_replication_group_ids["main"]
      num_cache_clusters          = 2
      subnet_group_name           = "my-subnet-group"
    }
  }
}
```

## Naming Convention

All resources follow the pattern: `{region_prefix}-{resource-type}-{account_name}-{project_name}-{key}`

| Resource                 | Example Name                           | Limit |
| ------------------------ | -------------------------------------- | ----- |
| Replication Group        | `ause1-redis-prod-myapp-main`          | 40    |
| Cluster                  | `ause1-cache-prod-myapp-main`          | 50    |
| Serverless Cache         | `ause1-sc-prod-myapp-main`             | 40    |
| Subnet Group             | `ause1-cache-subnet-prod-myapp-main`   |       |
| Parameter Group          | `ause1-cache-pg-prod-myapp-redis71`    |       |
| User Group               | `ause1-cache-ug-prod-myapp-main`       |       |
| Global Replication Group | `ause1-redis-global-prod-myapp-main` (suffix; AWS adds its own prefix) | |

- Generated names longer than the AWS limit are truncated (and never end with a hyphen). Truncation can make two long keys collide; use short keys or an explicit `name`.
- Every map entry accepts an optional `name` that replaces the generated name.
- Users keep `user_id`/`user_name` (default: the map key) because they are referenced by Redis/Valkey `AUTH`.
- The region prefix is derived from the provider region (34 regions mapped; unknown regions use the region name). Override it with `region_prefix` or disable it with `use_region_prefix = false`.
- Tags: `merge(tags_common, tags, <resource tags>, { Name = <name>, ManagedBy = "Terraform" })`. `tags` is a deprecated alias of `tags_common`.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.3  |
| aws       | >= 6.0  |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| `account_name` | Account name for resource naming (1-32 chars, `^[a-z0-9-]+$`) | `string` | n/a | yes |
| `project_name` | Project name for resource naming (1-32 chars, `^[a-z0-9-]+$`) | `string` | n/a | yes |
| `create` | Whether to create ElastiCache resources | `bool` | `true` | no |
| `region_prefix` | Region prefix override; derived from the provider region when `null` | `string` | `null` | no |
| `use_region_prefix` | Whether to include the region prefix in resource names | `bool` | `true` | no |
| `tags_common` | Common tags applied to all resources | `map(string)` | `{}` | no |
| `tags` | (Deprecated: use `tags_common`) Additional tags, merged after `tags_common` | `map(string)` | `{}` | no |
| `replication_groups` | Map of Redis/Valkey replication groups | `map(object)` | `{}` | no |
| `clusters` | Map of clusters (Memcached, standalone Redis/Valkey, replication group read replicas) | `map(object)` | `{}` | no |
| `serverless_caches` | Map of serverless caches | `map(object)` | `{}` | no |
| `subnet_groups` | Map of subnet groups | `map(object)` | `{}` | no |
| `parameter_groups` | Map of parameter groups | `map(object)` | `{}` | no |
| `users` | Map of ACL users | `map(object)` | `{}` | no |
| `user_groups` | Map of ACL user groups | `map(object)` | `{}` | no |
| `global_replication_groups` | Map of global replication groups (primary side) | `map(object)` | `{}` | no |

### `replication_groups` attributes

| Attribute | Type | Default | Notes |
| --------- | ---- | ------- | ----- |
| `name` | `string` | generated | Explicit replication group ID (max 40) |
| `description` | `string` | `"Redis replication group for <key>"` | |
| `engine` / `engine_version` | `string` | `"redis"` / `"7.1"` | `null` for global secondary members |
| `node_type` | `string` | `null` | Required unless `global_replication_group_id` is set |
| `num_cache_clusters` | `number` | `null` | Non-cluster mode; ignored when `num_node_groups` is set |
| `num_node_groups` / `replicas_per_node_group` | `number` | `null` | Cluster mode |
| `cluster_mode` | `string` | `null` | `enabled`, `disabled`, `compatible` |
| `port` | `number` | `6379` | |
| `parameter_group_name` / `parameter_group_key` | `string` | `null` | Name wins over key |
| `subnet_group_name` / `subnet_group_key` | `string` | `null` | Name wins over key |
| `security_group_ids` | `list(string)` | `[]` | |
| `automatic_failover_enabled` | `bool` | `true` | Forced to `true` when `multi_az_enabled`; needs `num_cache_clusters >= 2` |
| `multi_az_enabled` | `bool` | `false` | |
| `preferred_cache_cluster_azs` | `list(string)` | `[]` | |
| `at_rest_encryption_enabled` | `bool` | `true` | |
| `transit_encryption_enabled` | `bool` | `true` | Required by `auth_token` |
| `transit_encryption_mode` | `string` | `null` | `preferred`, `required` |
| `kms_key_id` | `string` | `null` | Only used when at-rest encryption is enabled |
| `auth_token` / `auth_token_update_strategy` | `string` | `null` | |
| `user_group_ids` / `user_group_key` | `list(string)` / `string` | `[]` / `null` | IDs win over key |
| `global_replication_group_id` | `string` | `null` | Join an existing global datastore as a secondary member |
| `maintenance_window`, `snapshot_window` | `string` | `null` | |
| `snapshot_retention_limit` | `number` | `7` | |
| `snapshot_arns`, `snapshot_name`, `final_snapshot_identifier` | | `[]` / `null` | |
| `auto_minor_version_upgrade` | `bool` | `true` | |
| `apply_immediately` | `bool` | `false` | |
| `notification_topic_arn` | `string` | `null` | |
| `data_tiering_enabled` | `bool` | `false` | r6gd nodes |
| `network_type`, `ip_discovery` | `string` | `null` | `ipv4`, `ipv6`, `dual_stack` |
| `log_delivery_configuration` | `list(object({destination, destination_type, log_format, log_type}))` | `[]` | `log_format` defaults to `json` |
| `timeouts` | `object({create, update, delete})` | `null` | |
| `tags` | `map(string)` | `{}` | |

### `clusters` attributes

| Attribute | Type | Default | Notes |
| --------- | ---- | ------- | ----- |
| `name` | `string` | generated | Explicit cluster ID (max 50) |
| `replication_group_id` / `replication_group_key` | `string` | `null` | Attach as a read replica (mutually exclusive) |
| `engine` / `engine_version` | `string` | `"memcached"` / `null` | |
| `node_type` | `string` | `null` | Required unless attached to a replication group |
| `num_cache_nodes` | `number` | `1` | |
| `port` | `number` | `11211` | Set `6379` explicitly for standalone Redis/Valkey |
| `az_mode`, `availability_zone` | `string` | `null` | |
| `preferred_availability_zones` | `list(string)` | `[]` | |
| `outpost_mode`, `preferred_outpost_arn` | `string` | `null` | |
| `parameter_group_name` / `parameter_group_key` | `string` | `null` | |
| `subnet_group_name` / `subnet_group_key` | `string` | `null` | |
| `security_group_ids` | `list(string)` | `[]` | |
| `maintenance_window`, `notification_topic_arn` | `string` | `null` | |
| `apply_immediately` | `bool` | `false` | |
| `auto_minor_version_upgrade` | `bool` | `true` | |
| `transit_encryption_enabled` | `bool` | `null` | |
| `network_type`, `ip_discovery` | `string` | `null` | |
| `snapshot_retention_limit`, `snapshot_window`, `snapshot_arns`, `snapshot_name`, `final_snapshot_identifier` | | `null` / `[]` | |
| `log_delivery_configuration` | `list(object)` | `[]` | Standalone Redis/Valkey only |
| `timeouts` | `object({create, update, delete})` | `null` | |
| `tags` | `map(string)` | `{}` | |

### `serverless_caches` attributes

| Attribute | Type | Default |
| --------- | ---- | ------- |
| `name` | `string` | generated (max 40) |
| `engine` | `string` | `"redis"` |
| `major_engine_version` | `string` | `"7"` |
| `description` | `string` | `"Serverless cache for <key>"` |
| `daily_snapshot_time`, `kms_key_id`, `user_group_id`, `user_group_key` | `string` | `null` |
| `security_group_ids`, `subnet_ids` | `list(string)` | `[]` |
| `snapshot_arns_to_restore` | `list(string)` | `null` |
| `snapshot_retention_limit` | `number` | `null` |
| `cache_usage_limits` | `object({data_storage = {maximum, minimum, unit}, ecpu_per_second = {maximum, minimum}})` | `null` |
| `timeouts` | `object({create, update, delete})` | `null` |
| `tags` | `map(string)` | `{}` |

### Other maps

| Variable | Attributes |
| -------- | ---------- |
| `subnet_groups` | `name`, `subnet_ids` (required), `description`, `tags` |
| `parameter_groups` | `name`, `family` (required), `description`, `parameters` (`list({name, value})`), `tags` |
| `users` | `user_id` (default key), `user_name` (default key), `access_string` (required), `engine` (`redis`), `no_password_required`, `passwords`, `authentication_mode` (`{type, passwords}`), `tags` |
| `user_groups` | `name`, `engine` (`redis`), `user_ids`, `user_keys`, `tags` |
| `global_replication_groups` | `name` (ID suffix), `global_replication_group_description`, `primary_replication_group_key` (required), `automatic_failover_enabled` (`true`), `cache_node_type`, `engine_version`, `parameter_group_name`, `num_node_groups` |

> `user_groups` ignores later changes to `user_ids` (`lifecycle.ignore_changes`), so adding or removing users after creation is not applied by Terraform.

## Outputs

| Name | Description |
| ---- | ----------- |
| `replication_groups` | Map of replication groups with `id`, `arn`, `engine_version_actual`, endpoints, `port`, `member_clusters`, `global_replication_group_id` |
| `replication_group_names` | Map of keys to replication group IDs (known at plan time) |
| `replication_group_ids` | Map of keys to IDs |
| `replication_group_arns` | Map of keys to ARNs |
| `replication_group_primary_endpoint_addresses` | Map of keys to primary endpoint addresses |
| `replication_group_reader_endpoint_addresses` | Map of keys to reader endpoint addresses |
| `replication_group_configuration_endpoint_addresses` | Map of keys to configuration endpoint addresses (cluster mode) |
| `clusters` | Map of clusters with `id`, `arn`, `engine_version_actual`, `cache_nodes`, `cluster_address`, `configuration_endpoint`, `replication_group_id` |
| `cluster_names` | Map of keys to cluster IDs (known at plan time) |
| `cluster_ids` | Map of keys to IDs |
| `cluster_arns` | Map of keys to ARNs |
| `cluster_addresses` | Map of keys to cluster addresses (Memcached) |
| `cluster_configuration_endpoints` | Map of keys to configuration endpoints (Memcached) |
| `serverless_caches` | Map of serverless caches with `arn`, `name`, versions, `status`, endpoints, `create_time` |
| `serverless_cache_names` | Map of keys to names |
| `serverless_cache_arns` | Map of keys to ARNs |
| `serverless_cache_endpoints` | Map of keys to endpoints |
| `serverless_cache_reader_endpoints` | Map of keys to reader endpoints |
| `subnet_group_names` / `subnet_group_arns` | Subnet group names / ARNs |
| `parameter_group_names` / `parameter_group_ids` / `parameter_group_arns` | Parameter group names / IDs / ARNs |
| `user_ids` / `user_arns` | ACL user IDs / ARNs |
| `user_group_ids` / `user_group_arns` | ACL user group IDs / ARNs |
| `global_replication_group_ids` / `global_replication_group_arns` | Global replication group IDs / ARNs |
| `global_replication_group_engine_version_actual` | Global replication group engine versions |
| `global_replication_group_node_groups` | Global replication group node groups |

## Examples

- [Redis Basic](examples/redis-basic/) - Single node replication group with parameter and subnet groups
- [Redis Cluster](examples/redis-cluster/) - Multi-shard cluster mode with replicas, multi-AZ and slow log delivery to CloudWatch
- [Memcached](examples/memcached/) - Cross-AZ Memcached cluster
- [Serverless](examples/serverless/) - Valkey serverless cache with usage limits
- [Valkey ACL](examples/valkey-acl/) - Valkey replication group with ACL users, user group and an extra read replica cluster

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
