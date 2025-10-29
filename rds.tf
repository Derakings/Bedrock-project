# RDS MySQL instance for catalog service
resource "aws_db_subnet_group" "catalog_mysql" {
  name       = "catalog-mysql-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "catalog-mysql-subnet-group"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_security_group" "catalog_mysql" {
  name        = "catalog-mysql-sg"
  description = "Security group for catalog MySQL RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL access from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "catalog-mysql-sg"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_db_instance" "catalog_mysql" {
  identifier             = "catalog-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  storage_encrypted      = true
  db_name                = "catalog"
  username               = "catalog"
  password               = "UD07xbLktgOwvXJ2"
  db_subnet_group_name   = aws_db_subnet_group.catalog_mysql.name
  vpc_security_group_ids = [aws_security_group.catalog_mysql.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = {
    Name        = "catalog-mysql"
    Environment = "dev"
    Terraform   = "true"
  }
}

# RDS PostgreSQL instance for orders service
resource "aws_db_subnet_group" "orders_postgresql" {
  name       = "orders-postgresql-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "orders-postgresql-subnet-group"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_security_group" "orders_postgresql" {
  name        = "orders-postgresql-sg"
  description = "Security group for orders PostgreSQL RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL access from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "orders-postgresql-sg"
    Environment = "dev"
    Terraform   = "true"
  }
}

resource "aws_db_instance" "orders_postgresql" {
  identifier             = "orders-postgresql"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  storage_encrypted      = true
  db_name                = "orders"
  username               = "orders"
  password               = "EQabaGSGlw2eL5sh"
  db_subnet_group_name   = aws_db_subnet_group.orders_postgresql.name
  vpc_security_group_ids = [aws_security_group.orders_postgresql.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = {
    Name        = "orders-postgresql"
    Environment = "dev"
    Terraform   = "true"
  }
}
