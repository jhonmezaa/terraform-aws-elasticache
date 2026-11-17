# Memcached Cluster

Creates a cross-AZ Memcached 1.6 cluster with 3 nodes, a custom parameter group and a subnet group.

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
| `cluster_id` | ID of the Memcached cluster. |
| `cluster_address` | DNS name of the Memcached cluster. |
| `cluster_configuration_endpoint` | Configuration endpoint of the Memcached cluster. |
| `parameter_group_name` | Name of the created parameter group. |
| `subnet_group_name` | Name of the created subnet group. |
