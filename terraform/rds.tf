data "aws_ssm_parameter" "DBNAME" {
  name = "/${var.project_name}/${var.environment}/DBNAME"
}
data "aws_ssm_parameter" "DBUSER" {
  name = "/${var.project_name}/${var.environment}/DBUSER"
}
data "aws_ssm_parameter" "DBPASSWORD" {
  name            = "/${var.project_name}/${var.environment}/DBPASSWORD"
  with_decryption = "true"
}


resource "aws_db_instance" "rds_mysqldb" {
  depends_on                      = [aws_db_subnet_group.mysql_subnet_group]
  identifier                      = data.aws_ssm_parameter.DBNAME.value
  allocated_storage               = 10
  storage_type                    = "gp2"
  engine                          = "mysql"
  engine_version                  = "5.7"
  instance_class                  = "db.t2.micro"
  multi_az                        = "false"
  username                        = data.aws_ssm_parameter.DBUSER.value
  password                        = data.aws_ssm_parameter.DBPASSWORD.value
  vpc_security_group_ids          = [aws_security_group.mysql_database_sg["app"].id]
  db_subnet_group_name            = aws_db_subnet_group.mysql_subnet_group.name
  backup_retention_period         = 7
  kms_key_id                      = aws_kms_key.database_kms.arn
  storage_encrypted               = "true"
  copy_tags_to_snapshot           = "true"
  deletion_protection             = "false"
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.enhancedmonitoring_role.arn
  parameter_group_name            = aws_db_parameter_group.mysqldb_param_group.name
  performance_insights_enabled    = "true"
  skip_final_snapshot             = "true"
}


resource "aws_db_parameter_group" "mysqldb_param_group" {
  description = "${local.name_prefix}-mysqlDB-Paramgroup"
  family      = "mysql5.7"
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

resource "aws_ssm_parameter" "mysql_param" {
  depends_on  = [aws_db_instance.rds_mysqldb]
  name        = "/${var.project_name}/${var.environment}/mysqldb_SERVER"
  description = "AWS RDS mysqlDB Server host name"
  type        = "String"
  value       = aws_db_instance.rds_mysqldb.address
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
  description = "${local.name_prefix}-subnetgroup"
  name        = "${local.name_prefix}-dbsubnetgroup"
  subnet_ids  = module.vpc.database_subnets
}

resource "aws_iam_role" "enhancedmonitoring_role" {
  name = "${local.name_prefix}-enhancedmonitoring_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  path                = "/"
}