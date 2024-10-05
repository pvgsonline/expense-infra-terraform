module "bastion" {
  source  = "git::https://github.com/pvgsonline/terraform-aws-ec2.git?ref=main"

  name = local.resource_name
  ami                    = data.aws_ami.rhel.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.sg_id]
  subnet_id              = local.public_subnet_id

  tags = merge (var.common_tags, {
    Name = local.resource_name
  }
  )
}
