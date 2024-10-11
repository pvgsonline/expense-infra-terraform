module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name
  ami                    = data.aws_ami.rhel.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.backend_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge (var.common_tags, {
    Name = local.resource_name
  }
  )
}

resource "null_resource" "ansible" {
  
  triggers = {
    instance_id=module.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.backend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"

  }

  provisioner "file" {
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh",
      "sudo sh /tmp/backend.sh ${var.component} ${var.environment}"
    ]
  }
}


