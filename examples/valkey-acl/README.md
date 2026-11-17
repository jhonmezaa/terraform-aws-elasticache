# Valkey ACL

Creates a Valkey 8 replication group (primary + replica, multi-AZ) with ACL users and a user group, plus an extra read replica cluster attached to the replication group through `clusters.replication_group_key`.

## Usage

```bash
terraform init
terraform plan \
  -var 'account_name=dev' \
  -var 'project_name=myapp' \
  -var 'private_subnet_ids=["subnet-aaa","subnet-bbb"]' \
  -var 'default_user_password=<16-128 chars>' \
  -var 'app_user_password=<16-128 chars>'
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
| `security_group_ids` | List of security group IDs for the replication group. | `[]` |
| `default_user_password` | Password for the disabled `default` ACL user (16-128 characters). | required |
| `app_user_password` | Password for the `app` ACL user (16-128 characters). | required |

## Outputs

| Name | Description |
| ---- | ----------- |
| `replication_group_id` | ID of the Valkey replication group. |
| `replication_group_primary_endpoint` | Primary endpoint address of the Valkey replication group. |
| `replication_group_reader_endpoint` | Reader endpoint address of the Valkey replication group. |
| `replica_cluster_id` | ID of the additional read replica cluster. |
| `user_group_id` | ID of the ACL user group. |
| `user_ids` | Map of ACL user keys to user IDs. |
