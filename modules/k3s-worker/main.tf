resource "aws_launch_template" "worker" {
  name_prefix   = "k3s-worker-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile { name = var.iam_instance_profile }

  user_data = base64encode(
    templatefile("${path.root}/userdata/k3s-worker.sh.tpl", {
      server_private_ip = var.server_private_ip
    })
  )

  network_interfaces {
    subnet_id       = var.private_subnet_id
    security_groups = [var.security_group_id]
  }
}

resource "aws_autoscaling_group" "worker_asg" {
  vpc_zone_identifier = [var.private_subnet_id]

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }

  # # Launch Template 변경 시 기존 인스턴스를 롤링으로 교체
  # instance_refresh {
  #   strategy = "Rolling"

  #   preferences {
  #     # 전체 인스턴스 중 최소 90%는 항상 Healthy 유지
  #     min_healthy_percentage = 90
  #     # 새 인스턴스가 워커로 붙고 k3s join될 시간을 여유 있게 줌(초)
  #     instance_warmup = 300
  #   }

  #   # Launch Template 변경 시에만 Instance Refresh 트리거
  #   triggers = ["launch_template"]
  # }
}

resource "aws_autoscaling_policy" "cpu_target" {
  depends_on = [
    aws_autoscaling_group.worker_asg
  ]
  name                   = "k3s-worker-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.worker_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
