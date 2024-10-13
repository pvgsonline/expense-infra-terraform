#backend instance
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

#configuring the instance with anisble script
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

#stopping the instance
resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  depends_on = [null_resource.ansible]
}

#taking the AMI snapshot
resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = module.backend.id
  depends_on = [aws_ec2_instance_state.backend]
}

#stopping the isntance
resource "null_resource" "backend" {
  
  triggers = {
    instance_id=module.backend.id
  }
  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
    
  }

  depends_on = [aws_ami_from_instance.backend]
} 

#create load balancer target groups
resource "aws_lb_target_group" "backend" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id


  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 5
    matcher = "200-299"
    path = "/health"
    port = 8080
    protocol = "HTTP"
    timeout = 4
  }
}

#create launch template
resource "aws_launch_template" "backend" {
  name = local.resource_name

  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"
  
  update_default_version = true

  vpc_security_group_ids = [local.backend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.resource_name
    }
  }
}

#create autoscaling
resource "aws_autoscaling_group" "backend" {
  name                      = local.resource_name
  max_size                  = 10
  min_size                  = 2
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  #force_delete              = true
  target_group_arns = [aws_lb_target_group.backend.arn]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
 
  tag {
    key                 = "Name"
    value               = local.resource_name
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "Expense"
    propagate_at_launch = false
  }
}

#create autoscaling policy
resource "aws_autoscaling_policy" "backend" {
  name = local.resource_name
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

#create autoscaling listerner rule
resource "aws_lb_listener_rule" "backend" {
  listener_arn = local.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["${var.component}.app-${var.environment}.${var.zone_name}"]
    }
  }
}
