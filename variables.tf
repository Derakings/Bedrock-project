variable "cidr" {}
variable "azs" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "cluster-name" {}

variable "catalog_db_username" {
  description = "Username for catalog MySQL database"
  type        = string
  default     = "catalog"
}

variable "catalog_db_password" {
  description = "Password for catalog MySQL database"
  type        = string
  sensitive   = true
  default     = "UD07xbLktgOwvXJ2"
}

variable "orders_db_username" {
  description = "Username for orders PostgreSQL database"
  type        = string
  default     = "orders"
}

variable "orders_db_password" {
  description = "Password for orders PostgreSQL database"
  type        = string
  sensitive   = true
  default     = "EQabaGSGlw2eL5sh"
}
