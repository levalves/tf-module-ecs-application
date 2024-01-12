#############
# ECS Cluster
#############
data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}

###############
# Load Balancer
###############
data "aws_lb" "nlb" {
  count = var.container_port != "" && var.nlb_listener_load_balancer_arn != null ? 1 : 0
  arn   = var.nlb_listener_load_balancer_arn
}

#######################
# Container Definitions
#######################
data "template_file" "container_definitions" {
  for_each = { for k, v in local.ecs_services : k => local.ecs_services[k] if v.enabled }

  template = file("${path.module}/templates/container-definitions.json")

  vars = {
    name               = each.value.name
    image              = each.value.container_image
    command            = jsonencode(each.value.container_cmd)
    essential          = each.value.container_essential
    environments       = jsonencode(each.value.container_environments)
    secrets            = jsonencode(each.value.container_secrets)
    port               = each.value.container_port
    host_port          = each.value.container_host_port
    protocol           = each.value.container_protocol
    cpu                = each.value.container_cpu
    memory             = each.value.container_memory
    memory_reservation = each.value.container_memory_reservation
    labels             = jsonencode(each.value.container_labels)
    health_check       = jsonencode(each.value.container_health_check)
  }
}

data "aws_ecs_service" "blue" {
  count = var.enabled_blue_green_deployment && !var.blue_green_is_first_deploy ? 1 : 0

  service_name = local.blue_service_name
  cluster_arn  = data.aws_ecs_cluster.this.arn
}

data "aws_ecs_task_definition" "blue" {
  count = var.enabled_blue_green_deployment && !var.blue_green_is_first_deploy ? 1 : 0

  task_definition = local.blue_service_name
}

data "aws_ecs_container_definition" "blue" {
  count = var.enabled_blue_green_deployment && !var.blue_green_is_first_deploy ? 1 : 0

  task_definition = data.aws_ecs_task_definition.blue[count.index].id
  container_name  = local.blue_service_name
}

data "aws_ecs_service" "green" {
  count = var.enabled_blue_green_deployment && !var.blue_green_is_first_deploy ? 1 : 0

  service_name = local.green_service_name
  cluster_arn  = data.aws_ecs_cluster.this.arn
}

data "aws_ecs_task_definition" "green" {
  count = !var.blue_green_is_first_deploy ? 1 : 0

  task_definition = local.green_service_name
}

data "aws_ecs_container_definition" "green" {
  count = var.enabled_blue_green_deployment && !var.blue_green_is_first_deploy ? 1 : 0

  task_definition = data.aws_ecs_task_definition.green[count.index].id
  container_name  = local.green_service_name
}
