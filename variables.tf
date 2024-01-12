#########
# General
#########
variable "name" {
  description = "Name to be used on all resources as identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to be used in the ECS Service."
  type        = string
}

variable "subnet_ids" {
  description = "List of Subnet IDs to be used in the ECS Service if `ecs_task_network_mode` has value set to `awsvpc`."
  type        = list(string)
}

variable "tags" {
  description = "Tags to be added to all resources."
  type        = map(string)
  default     = {}
}

##############
# AWS Settings
##############
variable "aws_role" {
  description = "AWS role to be used by this module to create records in Route53. Defaults to Pagzoop Production."
  type        = string
  default     = "arn:aws:iam::327667905059:role/CrossAccount-Pagzoop_Prod"
}

variable "aws_region" {
  description = "AWS region to be used by this module."
  type        = string
}

################
# Security Group
################
variable "sg_ingress_cidr_blocks" {
  description = "List of CIDR blocks for the ECS service security group."
  type        = list(string)
  default     = null
}

variable "sg_ingress_security_group_ids" {
  description = "List of  security groups IDs for the ECS service security group."
  type        = list(string)
  default     = null
}

#########
# Route53
#########
variable "domain_zone_id" {
  description = "Route53 zone ID to be used by this module."
  type        = string
  default     = null
}

variable "alb_dns_name" {
  description = "ALB DNS name to be used in alias route53 settings."
  type        = string
  default     = null
}

variable "alb_zone_id" {
  description = "ALB Zone ID to be used in alias route53 settings."
  type        = string
  default     = null
}

variable "domain" {
  description = "Domain to be added to route53 records."
  type        = string
  default     = null
}

variable "sub_domain" {
  description = "Sub domain to be added to route53 records."
  type        = string
  default     = ""
}

##############
# Target Group
##############
variable "tg_name" {
  description = "Target Group name, needed because of resource name size limitations."
  type        = string
  default     = null

  validation {
    condition     = length(var.tg_name) <= 32
    error_message = "Must be less than or equal to 32 characters."
  }
}

variable "tg_deregistration_delay" {
  description = "Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 60 seconds."
  type        = string
  default     = "60"
}

variable "tg_health_check_path" {
  description = "Destination for the health check request. The default value is `/`."
  type        = string
  default     = "/"
}

variable "tg_health_check_matcher" {
  description = "Response codes to use when checking for a healthy responses from a target. The default value is 200."
  type        = string
  default     = "200"
}

variable "tg_health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target. The default value is 5."
  type        = number
  default     = 5
}

variable "tg_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering a target healthy. The range is 2-10. The default value is 2."
  type        = number
  default     = 2
}

variable "tg_health_check_timeout" {
  description = "Amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds. The default value is 3."
  type        = number
  default     = 3
}

variable "tg_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy. The range is 2-10. Defaults to 2."
  type        = number
  default     = 2
}

##########################
# Load Balancer - Listener
##########################
variable "alb_listener_arn" {
  description = "ARN of the application load balancer used by the listener rule of ECS Service."
  type        = string
  default     = null
}

variable "alb_listener_rule_priority" {
  description = "Priority of the application load balancer used by the listener rule of ECS Service."
  type        = number
  default     = null
}

variable "nlb_listener_load_balancer_arn" {
  description = "ARN of the network load balancer used by the ECS service."
  type        = string
  default     = null
}

variable "nlb_listener_port" {
  description = "Port of the network load balancer used by the ECS service."
  type        = number
  default     = null
}

variable "nlb_listener_port_blue" {
  description = "Port of the network load balancer used by the ECS service blue."
  type        = number
  default     = null
}

variable "nlb_listener_port_green" {
  description = "Port of the network load balancer used by the ECS service green."
  type        = number
  default     = null
}

variable "nlb_listener_protocol" {
  description = "Protocol of the network load balancer used by the ECS service."
  type        = string
  default     = "TCP"
}

variable "nlb_listener_ssl_policy" {
  description = "SSL Policy of the network load balancer used by the ECS service."
  type        = string
  default     = null
}

variable "nlb_listener_ssl_certificate_arn" {
  description = "ARN SSL Certificate of the network load balancer used by the ECS service."
  type        = string
  default     = null
}

#################
# Task Definition
#################
variable "task_definition_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
  default     = null
}

variable "task_definition_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
  default     = null
}

variable "task_definition_efs_volumes" {
  description = "List of EFS volumes to make available for use on the container_definitions. Each item should be a map with 3 properties: name, file_system_id and root_directory."
  type        = list(any)
  default     = []
}

variable "task_definition_host_volumes" {
  description = "List of host volumes to make available for use on the container_definitions. Each item should be an object with 2 properties: name and host_path."
  type = list(object({
    name      = string
    host_path = string
  }))
  default = []
}

#######################
# Container Definitions
#######################
variable "container_port" {
  description = "Container port to used in the ECS Service."
  type        = string
  default     = ""
}

variable "container_host_port" {
  description = "Host port used in the container definitions settings."
  type        = number
  default     = 0
}

variable "container_protocol" {
  description = "Container protocol used in the container definitions settings."
  type        = string
  default     = "tcp"
}

variable "container_image" {
  description = "Image used in the container definitions settings."
  type        = string
}

variable "container_cpu" {
  description = "CPU used in the container definitions settings."
  type        = number
}

variable "container_memory" {
  description = "Memory used in the container definitions settings."
  type        = number
}

variable "container_memory_reservation" {
  description = "Memory reservation used in the container definitions settings."
  type        = number
}

variable "container_essential" {
  description = "Essential used in the container definitions settings."
  type        = bool
  default     = true
}

variable "container_cmd" {
  description = "CMD used in the container definitions settings."
  type        = list(string)
  default     = []
}

variable "container_environments" {
  description = "List of environment variables used in the container definitions settings."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "List of secret variables used in the container definitions settings."
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "container_labels" {
  description = "Map of docker labels used in the container definitions settings."
  type        = map(any)
  default     = {}
}

variable "container_health_check" {
  description = "Map of docker health check used in the container definitions settings."
  type = object({
    command     = list(string),
    interval    = number,
    retries     = number,
    startPeriod = number,
    timeout     = number
  })
  default = null
}

#############
# ECS Service
#############
variable "ecs_cluster_name" {
  description = "ECS Cluster name to ECS Service deploy."
  type        = string
}

variable "enabled_blue_green_deployment" {
  description = "If true, Blue/Green deployment is enabled."
  type        = bool
  default     = false
}

variable "blue_green_which_to_deploy" {
  description = "Which blue/green environment to deploy."
  type        = string
  default     = "blue"

  validation {
    condition     = contains(["", "blue", "green"], var.blue_green_which_to_deploy)
    error_message = "blue_green_which_to_deploy must be blue or green."
  }
}

variable "blue_green_traffic_distribution" {
  description = "Blue/Green distribution."
  type        = string
  default     = "blue"

  validation {
    condition     = contains(["blue", "blue-90", "split", "green-90", "green"], var.blue_green_traffic_distribution)
    error_message = "blue_green_traffic_distribution must be blue, blue-90, split, green-90 or green."
  }
}

variable "blue_green_stop_env" {
  description = "Promove blue/green environment to deploy."
  type        = string
  default     = ""

  validation {
    condition     = contains(["", "blue", "green"], var.blue_green_stop_env)
    error_message = "blue_green_stop_env must be empty string, blue or green."
  }
}

variable "blue_green_is_first_deploy" {
  description = "If true, Blue/Green deployment is set first deploy."
  type        = bool
  default     = false
}

variable "ecs_desired_count" {
  description = "Number of instances of the task definition to place and keep running."
  type        = number
}

variable "ecs_capacity_provider_strategies" {
  description = "Capacity provider strategy to use for the ECS Service."
  type = list(object({
    capacity_provider = string,
    weight            = number
  }))
  default = []
}

variable "ecs_wait_for_steady_state" {
  description = "If true, Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing."
  type        = bool
  default     = true
}

variable "ecs_ordered_placement_strategy" {
  description = "Changes ordered placement strategy of ECS service."
  type        = list(map(string))
  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    }
  ]
}

variable "ecs_deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a ECS service during a deployment."
  type        = string
  default     = "200"
}

variable "ecs_deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a ECS service during a deployment."
  type        = string
  default     = "100"
}

variable "ecs_health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers."
  type        = number
  default     = 0
}

variable "ecs_task_network_mode" {
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
  type        = string
  default     = "bridge"
}

variable "ecs_enable_auto_scaling_cpu" {
  description = "Enable auto scaling policies based on CPU if set to true."
  type        = bool
  default     = false
}

variable "ecs_enable_auto_scaling_mem" {
  description = "Enable auto scaling policies based on MEM if set to true."
  type        = bool
  default     = false
}

variable "ecs_max_capacity" {
  description = "Max capacity of the ECS Service."
  type        = number
  default     = 1
}

variable "ecs_min_capacity" {
  description = "Min capacity of the ECS Service."
  type        = number
  default     = 1
}

variable "ecs_cpu_scale_target_value" {
  description = "CPU target value for the metric."
  type        = number
  default     = 80
}

variable "ecs_cpu_scale_in_cooldown" {
  description = "CPU scale-in cooldown. Amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  type        = number
  default     = 180
}

variable "ecs_cpu_scale_out_cooldown" {
  description = "CPU scale-out cooldown. Amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  type        = number
  default     = 60
}

variable "ecs_scale_mem_target_value" {
  description = "Memory target value for the metric."
  type        = number
  default     = 80
}

variable "ecs_mem_scale_in_cooldown" {
  description = "Memory scale-in cooldown. Amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  type        = number
  default     = 180
}

variable "ecs_mem_scale_out_cooldown" {
  description = "Memory scale-out cooldown. Amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  type        = number
  default     = 60
}
