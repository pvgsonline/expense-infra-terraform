data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  name  = "/${var.project_name}/${var.environment}/public_subnet_id"
}

data "aws_ssm_parameter" "web_alb_sg_id" {
  name  = "/${var.project_name}/${var.environment}/web_alb_sg_id"
}

data "aws_ssm_parameter" "aws_acm_certificate_expense" {
name  = "/${var.project_name}/${var.environment}/aws_acm_certificate_expense"
}



