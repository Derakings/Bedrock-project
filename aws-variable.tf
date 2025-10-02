# Variables for AWS managed persistence resources

variable "catalog_db_name" {}
data "aws_ssm_parameter" "catalog_db_username" {
  name            = "/innovatemart/catalog/db_username"
  with_decryption = true
}

variable "catalog_db_username" {
  default = data.aws_ssm_parameter.catalog_db_username.value
}

data "aws_ssm_parameter" "catalog_db_password" {
  name            = "/innovatemart/catalog/db_password"
  with_decryption = true
}

variable "catalog_db_password" {
  description = "Catalog DB password"
  type        = string
}

variable "orders_db_name" {}
data "aws_ssm_parameter" "orders_db_username" {
  name            = "/innovatemart/orders/db_username"
  with_decryption = true
}

variable "orders_db_username" {
  default = data.aws_ssm_parameter.orders_db_username.value
}

data "aws_ssm_parameter" "orders_db_password" {
  name            = "/innovatemart/orders/db_password"
  with_decryption = true
}

variable "orders_db_password" {
  default = data.aws_ssm_parameter.orders_db_password.value
}

variable "carts_table_name" {}

resource "aws_db_instance" "catalog_mysql" {
  # ...other config...
  password = data.aws_ssm_parameter.catalog_db_password.value
}
