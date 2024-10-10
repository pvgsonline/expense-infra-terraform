module "app_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal=true
  enable_deletion_protection = false
  name    = local.resource_name
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_id

  # Security Group

 create_security_group = false

security_groups = [local.app_alb_sg_id]

  tags = var.common_tags

}

resource "aws_lb_listener" "gttp" {
  load_balancer_arn = module.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>hello this is a load balancer</h1>"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  

  zone_name = var.zone_name

  records = [
    {
      name    = "*.app-${var.environment}" #*.app-dev.pvgs.online
      type    = "A"
      alias   = {
        name    = module.app_alb.dns_name
        zone_id = module.app_alb.zone_id
      }
      allow_overwrite = true
    }
  ]

}
