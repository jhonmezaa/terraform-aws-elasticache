# Serverless Cache

Creates a Valkey 8 serverless cache with data storage and ECPU usage limits, daily snapshots and an optional customer managed KMS key.

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
| `private_subnet_ids` | List of private subnet IDs for the serverless cache. | required |
| `security_group_ids` | List of security group IDs for the serverless cache. | `[]` |
| `kms_key_arn` | ARN of a customer managed KMS key for encryption at rest. If null, an AWS owned key is used. | `null` |

## Outputs

| Name | Description |
| ---- | ----------- |
| `serverless_cache_name` | Name of the serverless cache. |
| `serverless_cache_arn` | ARN of the serverless cache. |
| `serverless_cache_endpoint` | Endpoint of the serverless cache. |
| `serverless_cache_reader_endpoint` | Reader endpoint of the serverless cache. |
