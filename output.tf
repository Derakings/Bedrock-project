output "password" {
  value = aws_iam_user_login_profile.developer.encrypted_password
}

output "catalog_mysql_endpoint" {
  description = "RDS MySQL endpoint for catalog service"
  value       = aws_db_instance.catalog_mysql.endpoint
}

output "orders_postgresql_endpoint" {
  description = "RDS PostgreSQL endpoint for orders service"
  value       = aws_db_instance.orders_postgresql.endpoint
}
