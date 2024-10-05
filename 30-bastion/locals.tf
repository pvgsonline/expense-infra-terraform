locals {
  resource_name = "${var.project_name}-${var.environment}-bastion"
  sg_id= data.aws_ssm_parameter.bastion_sg_id.value
  public_subnet_id=split(",",data.aws_ssm_parameter.public_subnet_id.value)[0]
}
