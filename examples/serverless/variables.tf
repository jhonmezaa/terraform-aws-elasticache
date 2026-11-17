variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the serverless cache."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the serverless cache."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "ARN of a customer managed KMS key for encryption at rest. If null, an AWS owned key is used."
  type        = string
  default     = null
}
