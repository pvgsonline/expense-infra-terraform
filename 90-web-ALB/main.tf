module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal=false
  enable_deletion_protection = false
  name    = local.resource_name
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_id

  # Security Group

 create_security_group = false

security_groups = [local.web_alb_sg_id]

  tags = var.common_tags

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.web_alb.arn
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

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_certificate_arn

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
      name    = "expense-${var.environment}" #expense-dev.pvgs.online
      type    = "A"
      alias   = {
        name    = module.web_alb.dns_name
        zone_id = module.web_alb.zone_id # This belongs ALB internal hosted zone, not ours
      }
      allow_overwrite = true
    }
  ]

}
