locals {
  traffic_dist_map = {
    blue = {
      blue  = 100
      green = 0
    }
    blue-90 = {
      blue  = 90
      green = 10
    }
    split = {
      blue  = 50
      green = 50
    }
    green-90 = {
      blue  = 10
      green = 90
    }
    green = {
      blue  = 0
      green = 100
    }
  }

  ecs_service_default_values = {
    name                               = var.name,
    tg_name                            = var.tg_name,
    record                             = var.sub_domain != "" ? "${try(var.domain, var.name)}.${var.sub_domain}" : try(var.domain, var.name),
    record_nlb                         = var.sub_domain != "" ? "${var.tg_name}-nlb.${var.sub_domain}" : "${var.tg_name}-nlb",
    desired_count                      = var.ecs_desired_count,
    deployment_minimum_healthy_percent = var.ecs_deployment_minimum_healthy_percent,
    deployment_maximum_percent         = var.ecs_deployment_maximum_percent,
    health_check_grace_period_seconds  = var.ecs_health_check_grace_period_seconds,
    wait_for_steady_state              = var.ecs_wait_for_steady_state,
    ecs_task_network_mode              = var.ecs_task_network_mode,
    ecs_ordered_placement_strategy     = var.ecs_ordered_placement_strategy,
    ecs_capacity_provider_strategies   = var.ecs_capacity_provider_strategies,
    task_definition_role_arn           = var.task_definition_role_arn,
    task_definition_execution_role_arn = var.task_definition_execution_role_arn,
    network_mode                       = var.ecs_task_network_mode,
    task_definition_efs_volumes        = var.task_definition_efs_volumes,
    task_definition_host_volumes       = var.task_definition_host_volumes,
    nlb_listener_port                  = var.nlb_listener_port,
    container_image                    = var.container_image,
    container_cmd                      = var.container_cmd,
    container_essential                = var.container_essential,
    container_environments             = var.container_environments,
    container_secrets                  = var.container_secrets,
    container_port                     = var.container_port,
    container_host_port                = var.container_host_port,
    container_protocol                 = var.container_protocol,
    container_cpu                      = var.container_cpu,
    container_memory                   = var.container_memory,
    container_memory_reservation       = var.container_memory_reservation,
    container_labels                   = var.container_labels,
    container_health_check             = var.container_health_check,
    tags                               = {}
  }

  blue_service_key  = "blue"
  green_service_key = "green"

  blue_service_name  = "${var.name}-${local.blue_service_key}"
  green_service_name = "${var.name}-${local.green_service_key}"

  ecs_services = {
    service = merge(local.ecs_service_default_values, {
      enabled           = !var.enabled_blue_green_deployment,
      enabled_extra_nlb = false,
      enabled_extra_alb = false
    }),
    blue = merge(local.ecs_service_default_values, {
      enabled           = var.enabled_blue_green_deployment,
      enabled_extra_nlb = var.enabled_blue_green_deployment && var.nlb_listener_load_balancer_arn != null,
      enabled_extra_alb = var.enabled_blue_green_deployment && var.container_port != "",
      name              = local.blue_service_name,
      tg_name           = "${var.tg_name}-${local.blue_service_key}",
      desired_count     = var.blue_green_stop_env == "blue" ? 0 : var.ecs_desired_count,
      nlb_listener_port = var.nlb_listener_port_blue,
      container_image   = var.blue_green_which_to_deploy == "blue" || var.blue_green_is_first_deploy ? var.container_image : data.aws_ecs_container_definition.blue[0].image,
      record            = var.sub_domain != "" ? "${try(var.domain, var.name)}-${local.blue_service_key}.${var.sub_domain}" : "${try(var.domain, var.name)}-${local.blue_service_key}",
      record_nlb        = var.sub_domain != "" ? "${var.tg_name}-${local.blue_service_key}-nlb.${var.sub_domain}" : "${var.tg_name}-${local.blue_service_key}-nlb"
    }),
    green = merge(local.ecs_service_default_values, {
      enabled           = var.enabled_blue_green_deployment,
      enabled_extra_nlb = var.enabled_blue_green_deployment && var.nlb_listener_load_balancer_arn != null,
      enabled_extra_alb = var.enabled_blue_green_deployment && var.container_port != "",
      name              = local.green_service_name,
      tg_name           = "${var.tg_name}-${local.green_service_key}",
      desired_count     = var.blue_green_stop_env == "green" ? 0 : var.ecs_desired_count,
      nlb_listener_port = var.nlb_listener_port_green,
      container_image   = var.blue_green_which_to_deploy == "green" || var.blue_green_is_first_deploy ? var.container_image : data.aws_ecs_container_definition.green[0].image,
      record            = var.sub_domain != "" ? "${try(var.domain, var.name)}-${local.green_service_key}.${var.sub_domain}" : "${try(var.domain, var.name)}-${local.green_service_key}",
      record_nlb        = var.sub_domain != "" ? "${var.tg_name}-${local.green_service_key}-nlb.${var.sub_domain}" : "${var.tg_name}-${local.green_service_key}-nlb"
    })
  }
}

#############
# ECS Service
#############
resource "aws_ecs_service" "default" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled }

  name                               = each.value.name
  cluster                            = data.aws_ecs_cluster.this.arn
  task_definition                    = aws_ecs_task_definition.default[each.key].arn
  desired_count                      = each.value.desired_count
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  health_check_grace_period_seconds  = each.value.health_check_grace_period_seconds
  wait_for_steady_state              = each.value.wait_for_steady_state
  tags                               = each.value.tags

  dynamic "load_balancer" {
    for_each = each.value.container_port != "" && var.enabled_blue_green_deployment ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.tg[each.key].arn
      container_name   = each.value.name
      container_port   = each.value.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.nlb_listener_load_balancer_arn != null && var.enabled_blue_green_deployment ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.tg_nlb[each.key].arn
      container_name   = each.value.name
      container_port   = each.value.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = local.ecs_service_default_values.container_port != "" && !var.enabled_blue_green_deployment ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.stable_tg[0].arn
      container_name   = each.value.name
      container_port   = local.ecs_service_default_values.container_port
    }
  }

  dynamic "load_balancer" {
    for_each = var.nlb_listener_load_balancer_arn != null ? [1] : []

    content {
      target_group_arn = aws_lb_target_group.stable_tg_nlb[0].arn
      container_name   = each.value.name
      container_port   = local.ecs_service_default_values.container_port
    }
  }

  dynamic "network_configuration" {
    for_each = each.value.ecs_task_network_mode == "awsvpc" ? [1] : []

    content {
      subnets         = var.subnets
      security_groups = [aws_security_group.default[0].id]
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = each.value.ecs_ordered_placement_strategy

    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = each.value.ecs_capacity_provider_strategies

    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  depends_on = [aws_ecs_task_definition.default]
}

#####################
# ECS Task Definition
#####################
resource "aws_ecs_task_definition" "default" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled }

  family                = each.value.name
  container_definitions = data.template_file.container_definitions[each.key].rendered
  task_role_arn         = each.value.task_definition_role_arn
  execution_role_arn    = each.value.task_definition_execution_role_arn
  network_mode          = each.value.ecs_task_network_mode

  dynamic "volume" {
    for_each = each.value.task_definition_efs_volumes

    content {
      name = volume.value["name"]

      efs_volume_configuration {
        file_system_id     = volume.value["file_system_id"]
        root_directory     = volume.value["root_directory"]
        transit_encryption = volume.value["transit_encryption"] != "ENABLED" ? "" : "ENABLED"

        dynamic "authorization_config" {
          for_each = volume.value["access_point_id"] != "" ? [1] : []

          content {
            access_point_id = volume.value["access_point_id"]
            iam             = volume.value["iam"] != "ENABLED" ? "" : "ENABLED"
          }
        }
      }
    }
  }

  dynamic "volume" {
    for_each = each.value.task_definition_host_volumes

    content {
      name      = volume.value["name"]
      host_path = volume.value["host_path"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

################
# Security Group
################
resource "aws_security_group" "default" {
  count = var.ecs_task_network_mode == "awsvpc" ? 1 : 0

  name        = var.name
  description = "Allow inbound/outbound traffic for ${var.name} ECS tasks"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.container_port != "" ? [1] : []

    content {
      from_port       = var.container_port
      to_port         = var.container_port
      protocol        = "tcp"
      cidr_blocks     = var.sg_ingress_cidr_blocks
      security_groups = var.sg_ingress_security_group_ids
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

################
# Route53 Record
################
resource "aws_route53_record" "default" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled_extra_alb }

  name     = each.value.record
  provider = aws.dst
  zone_id  = var.domain_zone_id
  type     = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nlb" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled_extra_nlb && var.container_port != "" }

  name     = each.value.record_nlb
  provider = aws.dst
  zone_id  = var.domain_zone_id
  type     = "CNAME"
  ttl      = 60
  records  = [data.aws_lb.nlb[0].dns_name]
}

resource "aws_route53_record" "stable_default" {
  count = var.container_port != "" ? 1 : 0

  name     = local.ecs_service_default_values.record
  provider = aws.dst
  zone_id  = var.domain_zone_id
  type     = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "stable_nlb" {
  count = var.nlb_listener_load_balancer_arn != null ? 1 : 0

  name     = local.ecs_service_default_values.record_nlb
  provider = aws.dst
  zone_id  = var.domain_zone_id
  type     = "CNAME"
  ttl      = 60
  records  = [data.aws_lb.nlb[0].dns_name]
}

#################
# App Autoscaling
#################
resource "aws_appautoscaling_target" "ecs_target" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled && (var.ecs_enable_auto_scaling_cpu || var.ecs_enable_auto_scaling_mem == true) }

  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.default[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_cpu" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled && var.ecs_enable_auto_scaling_cpu }

  name               = "${aws_ecs_service.default[each.key].name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_cpu_scale_target_value
    scale_in_cooldown  = var.ecs_cpu_scale_in_cooldown
    scale_out_cooldown = var.ecs_cpu_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "service_mem" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled && var.ecs_enable_auto_scaling_mem }

  name               = "${aws_ecs_service.default[each.key].name}-mem"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.ecs_scale_mem_target_value
    scale_in_cooldown  = var.ecs_mem_scale_in_cooldown
    scale_out_cooldown = var.ecs_mem_scale_out_cooldown
  }
}

###############
# Load Balancer
###############
resource "aws_lb_listener_rule" "default" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled_extra_alb }

  listener_arn = var.alb_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    host_header {
      values = [aws_route53_record.default[each.key].fqdn]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "stable_default" {
  count = var.container_port != "" ? 1 : 0

  listener_arn = var.alb_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = !var.enabled_blue_green_deployment ? aws_lb_target_group.stable_tg[count.index].arn : null

    dynamic "forward" {
      for_each = var.enabled_blue_green_deployment ? [1] : []

      content {
        target_group {
          arn    = aws_lb_target_group.tg[local.blue_service_key].arn
          weight = local.traffic_dist_map[var.blue_green_traffic_distribution][local.blue_service_key]
        }

        target_group {
          arn    = aws_lb_target_group.tg[local.green_service_key].arn
          weight = local.traffic_dist_map[var.blue_green_traffic_distribution][local.green_service_key]
        }

        stickiness {
          enabled  = false
          duration = 1
        }
      }
    }
  }

  condition {
    host_header {
      values = [aws_route53_record.stable_default[count.index].fqdn]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "nlb_listner" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled_extra_nlb }

  load_balancer_arn = var.nlb_listener_load_balancer_arn
  port              = each.value.nlb_listener_port
  protocol          = var.nlb_listener_protocol
  ssl_policy        = var.nlb_listener_protocol == "TLS" ? var.nlb_listener_ssl_policy : null
  certificate_arn   = var.nlb_listener_protocol == "TLS" ? var.nlb_listener_ssl_certificate_arn : null

  default_action {
    target_group_arn = aws_lb_target_group.tg_nlb[each.key].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "stable_nlb_listner" {
  count = var.nlb_listener_load_balancer_arn != null ? 1 : 0

  load_balancer_arn = var.nlb_listener_load_balancer_arn
  port              = local.ecs_service_default_values.nlb_listener_port
  protocol          = var.nlb_listener_protocol
  ssl_policy        = var.nlb_listener_protocol == "TLS" ? var.nlb_listener_ssl_policy : null
  certificate_arn   = var.nlb_listener_protocol == "TLS" ? var.nlb_listener_ssl_certificate_arn : null

  default_action {
    target_group_arn = aws_lb_target_group.stable_tg_nlb[count.index].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled_extra_alb }

  name                 = each.value.tg_name
  port                 = each.value.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = each.value.ecs_task_network_mode == "awsvpc" ? "ip" : "instance"
  deregistration_delay = var.tg_deregistration_delay

  health_check {
    protocol            = "HTTP"
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
    interval            = var.tg_health_check_interval
    path                = var.tg_health_check_path
    timeout             = var.tg_health_check_timeout
    matcher             = var.tg_health_check_matcher
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "stable_tg" {
  count = var.container_port != "" && !var.enabled_blue_green_deployment ? 1 : 0

  name                 = local.ecs_service_default_values.tg_name
  port                 = local.ecs_service_default_values.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = local.ecs_service_default_values.ecs_task_network_mode == "awsvpc" ? "ip" : "instance"
  deregistration_delay = var.tg_deregistration_delay

  health_check {
    protocol            = "HTTP"
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
    interval            = var.tg_health_check_interval
    path                = var.tg_health_check_path
    timeout             = var.tg_health_check_timeout
    matcher             = var.tg_health_check_matcher
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "tg_nlb" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled_extra_nlb }

  name                 = "${each.value.tg_name}-nlb"
  port                 = each.value.container_port
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = each.value.ecs_task_network_mode == "awsvpc" ? "ip" : "instance"
  deregistration_delay = var.tg_deregistration_delay
}

resource "aws_lb_target_group" "stable_tg_nlb" {
  count = var.nlb_listener_load_balancer_arn != null ? 1 : 0

  name                 = "${local.ecs_service_default_values.tg_name}-nlb"
  port                 = local.ecs_service_default_values.container_port
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = local.ecs_service_default_values.ecs_task_network_mode == "awsvpc" ? "ip" : "instance"
  deregistration_delay = var.tg_deregistration_delay
}
