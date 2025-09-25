data "aws_caller_identity" "current" {}

resource "aws_db_subnet_group" "rds" {
  count      = var.enable_bonus_resources ? 1 : 0
  name       = "${var.project}-rds-subnets"
  subnet_ids = module.vpc.private_subnets
  tags = {
    Project = var.project
  }
}

resource "aws_security_group" "rds" {
  count       = var.enable_bonus_resources ? 1 : 0
  name        = "${var.project}-rds-sg"
  description = "Allow DB access from EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  ingress {
    description     = "Postgres from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
  }
}

resource "random_password" "catalog_mysql_password" {
  count   = var.enable_bonus_resources ? 1 : 0
  length  = 20
  special = true
}

resource "aws_db_instance" "catalog_mysql" {
  count                  = var.enable_bonus_resources ? 1 : 0
  identifier             = "${var.project}-catalog-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  db_name                = "catalog"
  username               = var.catalog_mysql_username
  password               = random_password.catalog_mysql_password[0].result
  db_subnet_group_name   = aws_db_subnet_group.rds[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  allocated_storage      = 20
  storage_type           = "gp3"
  skip_final_snapshot    = true
  publicly_accessible    = false
  deletion_protection    = false
  apply_immediately      = true
  tags = {
    Project = var.project
  }
}

resource "random_password" "orders_pg_password" {
  count   = var.enable_bonus_resources ? 1 : 0
  length  = 20
  special = true
  # RDS forbids '/', '@', '"', and space in master passwords. Limit special chars accordingly.
  override_special = "!#$%^&*()-_=+[]{}:,.?~"
  min_special      = 1
}

resource "aws_db_instance" "orders_postgres" {
  count                  = var.enable_bonus_resources ? 1 : 0
  identifier             = "${var.project}-orders-postgres"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t4g.micro"
  db_name                = "orders"
  username               = var.orders_pg_username
  password               = random_password.orders_pg_password[0].result
  db_subnet_group_name   = aws_db_subnet_group.rds[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  allocated_storage      = 20
  storage_type           = "gp3"
  skip_final_snapshot    = true
  publicly_accessible    = false
  deletion_protection    = false
  apply_immediately      = true
  tags = {
    Project = var.project
  }
}

resource "aws_dynamodb_table" "carts" {
  count        = var.enable_bonus_resources ? 1 : 0
  name         = "Items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = var.project
  }
}

locals {
  oidc_provider_url = replace(module.eks.oidc_provider_arn, ".*oidc-provider/", "")
}

# IRSA role for carts service account to access DynamoDB table
data "aws_iam_policy_document" "carts_dynamo_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = var.enable_bonus_resources ? [aws_dynamodb_table.carts[0].arn] : ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/nonexistent-disabled"]
  }
}

resource "aws_iam_policy" "carts_dynamo" {
  count       = var.enable_bonus_resources ? 1 : 0
  name        = "${var.project}-carts-dynamo"
  description = "Allow carts service to access DynamoDB table"
  policy      = data.aws_iam_policy_document.carts_dynamo_policy.json
}

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values = [
        "system:serviceaccount:${var.k8s_namespace}:carts"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "carts_irsa" {
  count              = var.enable_bonus_resources ? 1 : 0
  name               = "${var.project}-carts-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

resource "aws_iam_role_policy_attachment" "carts_attach" {
  count      = var.enable_bonus_resources ? 1 : 0
  role       = aws_iam_role.carts_irsa[0].name
  policy_arn = aws_iam_policy.carts_dynamo[0].arn
}

output "catalog_mysql_endpoint" {
  value = var.enable_bonus_resources ? aws_db_instance.catalog_mysql[0].address : ""
}

output "orders_postgres_endpoint" {
  value = var.enable_bonus_resources ? aws_db_instance.orders_postgres[0].address : ""
}

output "catalog_mysql_endpoint_with_port" {
  value = var.enable_bonus_resources ? format("%s:%d", aws_db_instance.catalog_mysql[0].address, aws_db_instance.catalog_mysql[0].port) : ""
}

output "orders_postgres_endpoint_with_port" {
  value = var.enable_bonus_resources ? format("%s:%d", aws_db_instance.orders_postgres[0].address, aws_db_instance.orders_postgres[0].port) : ""
}

output "catalog_mysql_username" {
  value = var.enable_bonus_resources ? aws_db_instance.catalog_mysql[0].username : ""
}

output "orders_pg_username" {
  value = var.enable_bonus_resources ? aws_db_instance.orders_postgres[0].username : ""
}

output "catalog_mysql_password" {
  value     = var.enable_bonus_resources ? random_password.catalog_mysql_password[0].result : ""
  sensitive = true
}

output "orders_pg_password" {
  value     = var.enable_bonus_resources ? random_password.orders_pg_password[0].result : ""
  sensitive = true
}

output "carts_table_name" {
  value = var.enable_bonus_resources ? aws_dynamodb_table.carts[0].name : ""
}

output "carts_irsa_role_arn" {
  value = var.enable_bonus_resources ? aws_iam_role.carts_irsa[0].arn : ""
}
