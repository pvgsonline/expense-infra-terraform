locals {
  resource_name = "${var.project_name}-${var.environment}-web-alb"
  web_alb_sg_id= data.aws_ssm_parameter.web_alb_sg_id.value
  public_subnet_id=split(",",data.aws_ssm_parameter.public_subnet_id.value)
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  https_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_expense.value
}
