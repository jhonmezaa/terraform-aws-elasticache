# Terraform AWS ElastiCache Module

Production-ready Terraform module for AWS ElastiCache supporting Redis replication groups, Memcached clusters, serverless caches, and all supporting resources.

## Features

- **Redis Replication Groups** - Primary/replica with automatic failover, multi-AZ, cluster mode (sharding)
- **Memcached Clusters** - Single-AZ and cross-AZ distributed caching
- **Serverless Caches** - Auto-scaling Redis and Memcached with usage limits
- **Subnet Groups** - Network isolation for cache nodes
- **Parameter Groups** - Custom engine configuration
- **Users & User Groups** - Redis ACL for fine-grained access control
- **Global Replication Groups** - Cross-region replication for disaster recovery
- **Encryption** - At-rest (KMS) and in-transit (TLS) encryption
- **Logging** - CloudWatch Logs and Kinesis Firehose delivery
- **Consistent Naming** - Region-aware naming convention across all resources

## Usage

### Redis Replication Group (Basic)

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache"

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
      security_group_ids  = ["sg-abc123"]

      automatic_failover_enabled = true
      multi_az_enabled           = true
    }
  }
}
```

### Redis Cluster Mode (Sharding)

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache"

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
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache"

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

### Serverless Cache

```hcl
module "elasticache" {
  source = "github.com/jhonmezaa/terraform-aws-elasticache//elasticache"

  account_name = "prod"
  project_name = "myapp"

  serverless_caches = {
    main = {
      engine               = "redis"
      major_engine_version = "7"
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

## Naming Convention

All resources follow the pattern: `{region_prefix}-{resource-type}-{account_name}-{project_name}-{key}`

| Resource             | Example Name                            |
|----------------------|-----------------------------------------|
| Replication Group    | `ause1-redis-prod-myapp-main`           |
| Cluster              | `ause1-cache-prod-myapp-main`           |
| Serverless Cache     | `ause1-cache-prod-myapp-main`           |
| Subnet Group         | `ause1-cache-subnet-prod-myapp-main`    |
| Parameter Group      | `ause1-cache-pg-prod-myapp-redis71`     |
| User Group           | `ause1-cache-ug-prod-myapp-main`        |

Region prefix is auto-detected from the AWS provider region (29 regions supported). Override with `region_prefix` variable or disable with `use_region_prefix = false`.

## Requirements

| Name      | Version |
|-----------|---------|
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |

## Examples

- [Redis Basic](examples/redis-basic/) - Single node replication group with parameter and subnet groups
- [Redis Cluster](examples/redis-cluster/) - Multi-shard cluster mode with replicas and multi-AZ
- [Memcached](examples/memcached/) - Cross-AZ Memcached cluster

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
