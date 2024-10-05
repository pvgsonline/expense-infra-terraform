module "db" {
  source = "terraform-aws-modules/rds/aws"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.small"
  allocated_storage = 5

  db_name  = local.resource_name
  username = "user"
  manage_master_user_password = false
  password = "ExpenseApp1"
  port     = "3306"


  vpc_security_group_ids = local.mysql_sg_id

  tags = var.common_tags

  # DB subnet group
 db_subnet_group_id = local.db_subnet_group_name

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

 skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}