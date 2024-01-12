#############
# ECS Service
#############
output "ecs_service_arn" {
  value       = compact([for s in aws_ecs_service.default : s.id])
  description = "ARN of the ECS service."
}

output "ecs_service_name" {
  value       = compact([for s in aws_ecs_service.default : s.name])
  description = "Name of the ECS service."
}

output "ecs_service_cluster" {
  value       = distinct(compact([for s in aws_ecs_service.default : s.cluster]))
  description = "Cluster ARN of the ECS service."
}

output "ecs_service_desired_count" {
  value       = compact([for s in aws_ecs_service.default : s.desired_count])
  description = "Desired count of the ECS service."
}

#####################
# ECS Task Definition
#####################
output "ecs_task_definition_arn" {
  value       = compact([for t in aws_ecs_task_definition.default : t.arn])
  description = "ARN of the ECS task definition."
}

output "ecs_task_definition_family" {
  value       = compact([for t in aws_ecs_task_definition.default : t.family])
  description = "Family of the ECS task definition."
}

output "ecs_task_definition_revision" {
  value       = compact([for t in aws_ecs_task_definition.default : t.revision])
  description = "Revision of the ECS task definition."
}

#######################
# Container Definitions
#######################
output "container_definitions_rendered" {
  value       = compact([for d in data.template_file.container_definitions : d.rendered])
  description = "Container definitions data rendered."
}

#########
# Route53
#########
output "route53_alb_name" {
  value       = compact([for t in aws_route53_record.default : t.name])
  description = "Default name of the Route53."
}

output "route53_alb_fqdn" {
  value       = compact([for t in aws_route53_record.default : t.fqdn])
  description = "Default fqdn of the Route53."
}

output "route53_nlb_name" {
  value       = compact([for t in aws_route53_record.nlb : t.name])
  description = "NLB name of the Route53."
}

output "route53_nlb_fqdn" {
  value       = compact([for t in aws_route53_record.nlb : t.fqdn])
  description = "NLB fqdn of the Route53."
}

###############
# Load Balancer
###############
output "target_group_alb_arn" {
  value       = compact([for t in aws_lb_target_group.tg : t.arn])
  description = "ARN of the ALB target group."
}

output "target_group_nlb_arn" {
  value       = compact([for t in aws_lb_target_group.tg_nlb : t.arn])
  description = "ARN of the NLB target group."
}

################
# Security Group
################
output "security_group_id" {
  value       = aws_security_group.default.*.id
  description = "Security group ID used by the ECS service."
}

output "security_group_arn" {
  value       = aws_security_group.default.*.arn
  description = "Security group ARN used by the ECS service."
}
