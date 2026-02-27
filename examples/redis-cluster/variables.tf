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

variable "vpc_id" {
  description = "VPC ID for the ElastiCache subnet group."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ElastiCache subnet group."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ElastiCache cluster."
  type        = list(string)
  default     = []
}
