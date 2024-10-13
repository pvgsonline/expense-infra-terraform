#security groups crareted for mysql,frontend,backend,bastion and ansible servers

module "mysql_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "mysql"

}

module "backend_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "backend"

}

module "frontend_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "frontend"

}

module "bastion_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "bastion"
}

module "ansible_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "ansible"
}

module "app_alb_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "app-alb"
}

module "vpn_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "vpn"
}

module "web_alb_sg"{
    source = "../../terraform-aws-security-group"
    vpc_id = local.vpc_id
    project_name = var.project_name
    environment = var.environment
    common_tags = var.common_tags
    security_group_name = "web_alb_sg"
}

resource "aws_security_group_rule" "mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id  = module.backend_sg.id
  security_group_id = module.mysql_sg.id
}


# resource "aws_security_group_rule" "backend" {
#   type              = "ingress"
#   from_port         = 8080
#   to_port           = 8080
#   protocol          = "tcp"
#   source_security_group_id  = module.frontend_sg.id
#   security_group_id = module.backend_sg.id
# }

resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id  = module.app_alb_sg.id
  security_group_id = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id  = module.frontend_sg.id
  security_group_id = module.app_alb_sg.id
}

# resource "aws_security_group_rule" "frontend" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks  = ["0.0.0.0/0"]
#   security_group_id = module.frontend_sg.id
# }


resource "aws_security_group_rule" "bastion_mysql" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.bastion_sg.id
  security_group_id = module.mysql_sg.id

}

resource "aws_security_group_rule" "bastion_backend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.bastion_sg.id
  security_group_id = module.backend_sg.id

}

resource "aws_security_group_rule" "bastion_app_alb" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.bastion_sg.id
  security_group_id = module.app_alb_sg.id

}

resource "aws_security_group_rule" "bastion_frontend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.bastion_sg.id
  security_group_id = module.frontend_sg.id

}

resource "aws_security_group_rule" "ansible_mysql" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.ansible_sg.id
  security_group_id = module.mysql_sg.id

}

resource "aws_security_group_rule" "ansible_backend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.ansible_sg.id
  security_group_id = module.backend_sg.id

}

resource "aws_security_group_rule" "ansible_frontend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.ansible_sg.id
  security_group_id = module.frontend_sg.id

}

resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.ansible_sg.id

}

resource "aws_security_group_rule" "vpn_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id

}

resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id

}

resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id

}

resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id

}

resource "aws_security_group_rule" "vpn_app_alb_new" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id  = module.vpn_sg.id
  security_group_id = module.app_alb_sg.id

}


resource "aws_security_group_rule" "vpn_mysql" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.vpn_sg.id
  security_group_id = module.mysql_sg.id

}

resource "aws_security_group_rule" "vpn_backend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.vpn_sg.id
  security_group_id = module.backend_sg.id

}

resource "aws_security_group_rule" "vpn_backend_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id  = module.vpn_sg.id
  security_group_id = module.backend_sg.id

}


resource "aws_security_group_rule" "vpn_frontend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.vpn_sg.id
  security_group_id = module.frontend_sg.id

}


resource "aws_security_group_rule" "web_alb_sg_frontend" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id  = module.web_alb_sg.id
  security_group_id = module.frontend_sg.id

}

resource "aws_security_group_rule" "web_alb_sg_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id

}

resource "aws_security_group_rule" "web_alb_sg_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id

}

resource "aws_security_group_rule" "web_alb_sg_frontend_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80 
  protocol          = "tcp"
  source_security_group_id  = module.web_alb_sg.id
  security_group_id = module.frontend_sg.id

}






