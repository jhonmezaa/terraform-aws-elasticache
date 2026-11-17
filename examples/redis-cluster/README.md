# Redis Cluster Mode

Creates a Redis 7.1 cluster mode replication group with 3 shards and 2 replicas per shard, multi-AZ, automatic failover, TLS required, and slow log delivery to a CloudWatch log group created by the example.

## Usage

```bash
terraform init
terraform plan \
  -var 'account_name=dev' \
  -var 'project_name=myapp' \
  -var 'private_subnet_ids=["subnet-aaa","subnet-bbb"]'
terraform apply
```

Resources created by this example cost money. Run `terraform destroy` when you no longer need them.

## Inputs

| Name | Description | Default |
| ---- | ----------- | ------- |
| `aws_region` | AWS region to deploy resources. | `"us-east-1"` |
| `account_name` | Account name for resource naming. | required |
| `project_name` | Project name for resource naming. | required |
| `private_subnet_ids` | List of private subnet IDs for the ElastiCache subnet group. | required |
| `security_group_ids` | List of security group IDs for the ElastiCache cluster. | `[]` |
| `log_retention_in_days` | Retention in days for the Redis slow log CloudWatch log group. | `14` |

## Outputs

| Name | Description |
| ---- | ----------- |
| `replication_group_id` | ID of the Redis cluster mode replication group. |
| `replication_group_configuration_endpoint` | Configuration endpoint address of the Redis cluster mode replication group. |
| `replication_group_member_clusters` | Member clusters of the Redis cluster mode replication group. |
| `parameter_group_name` | Name of the created parameter group. |
| `subnet_group_name` | Name of the created subnet group. |
