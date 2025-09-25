variable "project" {
  description = "Project tag/name"
  type        = string
  default     = "bedrock-project"
}

variable "enable_bonus_resources" {
  description = "If true, creates RDS, DynamoDB and IRSA resources (cost-bearing). Defaults to false to avoid accidental costs."
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "catalog_mysql_username" {
  description = "Username for the catalog MySQL RDS"
  type        = string
  default     = "catalog"
}

variable "orders_pg_username" {
  description = "Username for the orders Postgres RDS"
  type        = string
  default     = "orders"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for service accounts"
  type        = string
  default     = "default"
}
