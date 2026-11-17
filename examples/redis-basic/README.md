# Redis Basic

Creates a single-node Redis 7.1 replication group with a custom parameter group, a subnet group, at-rest and in-transit encryption and daily snapshots.

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

## Outputs

| Name | Description |
| ---- | ----------- |
| `replication_group_id` | ID of the Redis replication group. |
| `replication_group_primary_endpoint` | Primary endpoint address of the Redis replication group. |
| `parameter_group_name` | Name of the created parameter group. |
| `subnet_group_name` | Name of the created subnet group. |
