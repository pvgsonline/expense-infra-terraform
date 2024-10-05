locals {
  resource_name = "${var.project_name}-${var.environment}"
  db_sg_id= data.aws_ssm_parameter.mysql_sg_id.value
  db_subnet_group_name=data.database_subnet_group_name
}
