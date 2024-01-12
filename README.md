# Terraform Module | ECS Application

> A versão 6.x.x do módulo suporta o Terraform 1.0.x, caso precise utilizar um Terraform mais antigo a versão 3.x.x do módulo suporta o Terrraform 0.12.x.

Terraform (bare mininum and very opinionated) module to provision applications
on AWS ECS cluster as described on [ECS Zoop documentation](https://pag-zoop.atlassian.net/wiki/spaces/DEVOPS/pages/469991537/ECS#Estrutura-do-c%C3%B3digo-Terraform).

This module can create an AWS Application Auto Scaling target and auto scaling policies, based on CPU and Memory. To enable it set `enable_auto_scaling_cpu` or `enable_auto_scaling_mem` var as `true`.

Later versions of this module was configured to enforce `task_network_mode` as `awsvpc`. If you want to upgrade your module version and continue using it, don't forget to include `task_network_mode = "awsvpc"` at module configuration file. 

## Older versions:

- [v0](https://github.com/getzoop/tf-module-ecs-application/tree/v0)
- [v1](https://github.com/getzoop/tf-module-ecs-application/tree/v1)
- [v2](https://github.com/getzoop/tf-module-ecs-application/tree/v2)
- [v3](https://github.com/getzoop/tf-module-ecs-application/tree/v3)
- [v4](https://github.com/getzoop/tf-module-ecs-application/tree/v4)
- [v5](https://github.com/getzoop/tf-module-ecs-application/tree/v5)
- [v6](https://github.com/getzoop/tf-module-ecs-application/tree/v6)

## Usage
```
module "ecs_service" {
  source  = "git@github.com:getzoop/tf-module-ecs-application.git?ref=v6"

  name         = "my-service-name"
  tg_name      = "short-sn"
  cluster_name = "my-cluster-name"

  ecs_cluster_arn = "arn:aws:ecs:us-east-1:327667905059:cluster/my-cluster-name"
  vpc_id          = "vpc-b421asd"
  subnets         = ["subnet-foo123", "subnet-bar321dsa"]

  deregistration_delay  = "0"
  health_check_path     = "/health"
  health_check_matcher  = "200"
  health_check_interval = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 2
  health_check_timeout  = 3

  container_definitions = <<-EOF
      [
          {
              "name": "app-name",
              "image": "docker.io/nginx:latest",
              "memory": 512,
              "cpu": 512,
              "portMappings": [
                  {
                      "containerPort": 8080,
                      "hostPort": 0
                  }
              ],
              "logConfiguration": {
                  "logDriver": "fluentd",
                      "options": {
                      "fluentd-async-connect": "true",
                      "tag": "app-name-on-graylog"
                  }
              }
          }
      ]
  EOF

  container_port = 8080
  desired_count  = 1

  health_check_grace_period_seconds = 15

  alb_listener_arn           = "arn:aws:elasticloadbalancing:us-east-1:327667905059:listener/app/myalb/0be66aa88df2017b/a91be507975654bb"
  alb_listener_rule_priority = 99

  alb_dns_name   = "internal-my-alb-1116417726.us-east-1.elb.amazonaws.com"
  alb_zone_id    = "Z35SXDOTRQ7X7K"
  domain_zone_id = "ZX314UFXAPCZ2F"
  sub_domain     = var.environment == "production" ? "" : var.environment

  enable_auto_scaling_cpu = true
  cpu_scale_in_cooldown   = 300
  max_capacity            = 10

  nlb_listner_settings = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:327667905059:loadbalancer/net/my-nlb/0ae44103fff3c003",
    port              = 6443,
    ssl = {
      policy          = "ELBSecurityPolicy-2016-08"
      certificate_arn = "arn:aws:acm:us-east-1:327667905059:certificate/e92b2118-498f-41da-ad29-96a5979e7ef1"
    }
  }

  host_volumes = [
    {
      name = "docker",
      host_path = "/var/run/docker.sock"
    },
    {
      name = "root",
      host_path = "/"
    }
  ]

  efs_volumes = [
    {
      name               = "my-efs-volume-1",
      file_system_id     = aws_efs_file_system.my_fs.id,
      root_directory     = "/"
      transit_encryption = "ENABLED"
      access_point_id    = aws_efs_access_point.my_ap_1.id
      iam                = "ENABLED"
    },
    {
      name               = "my-efs-volume-2",
      file_system_id     = aws_efs_file_system.my_fs.id,
      root_directory     = "/"
      transit_encryption = "ENABLED"
      access_point_id    = aws_efs_access_point.my_ap_2.id
      iam                = "ENABLED"
    }
  ]

  capacity_provider_strategies = [{
    capacity_provider = "capacity-provider-name"
    weight = 100
  }]

  tags = {
    key1 = "value1"
  }
}
```

## Full Functional Example:

- [Using a NLB Listener](examples/nlb_listener/):

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| template | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.0.0 |
| aws.dst | 5.0.0 |
| template | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.service_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.service_mem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb_listener.nlb_listner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.tg_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [template_file.container_definitions](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| <a name="input_alb_dns_name"></a> [alb\_dns\_name](#input\_alb\_dns\_name) | ALB DNS name to be used in alias route53 settings. | `string` | `null` | no |
| <a name="input_alb_listener_arn"></a> [alb\_listener\_arn](#input\_alb\_listener\_arn) | ARN of the application load balancer used by the listener rule of ECS Service. | `string` | `null` | no |
| <a name="input_alb_listener_rule_priority"></a> [alb\_listener\_rule\_priority](#input\_alb\_listener\_rule\_priority) | Priority of the application load balancer used by the listener rule of ECS Service. | `number` | `null` | no |
| <a name="input_alb_zone_id"></a> [alb\_zone\_id](#input\_alb\_zone\_id) | ALB Zone ID to be used in alias route53 settings. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to be used by this module. | `string` | n/a | yes |
| <a name="input_aws_role"></a> [aws\_role](#input\_aws\_role) | AWS role to be used by this module to create records in Route53. Defaults to Pagzoop Production. | `string` | `"arn:aws:iam::327667905059:role/CrossAccount-Pagzoop_Prod"` | no |
| <a name="input_container_cmd"></a> [container\_cmd](#input\_container\_cmd) | CMD used in the container definitions settings. | `list(string)` | `[]` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | CPU used in the container definitions settings. | `number` | n/a | yes |
| <a name="input_container_environments"></a> [container\_environments](#input\_container\_environments) | List of environment variables used in the container definitions settings. | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | `[]` | no |
| <a name="input_container_essential"></a> [container\_essential](#input\_container\_essential) | Essential used in the container definitions settings. | `bool` | `true` | no |
| <a name="input_container_host_port"></a> [container\_host\_port](#input\_container\_host\_port) | Host port used in the container definitions settings. | `number` | `0` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Image used in the container definitions settings. | `string` | n/a | yes |
| <a name="input_container_labels"></a> [container\_labels](#input\_container\_labels) | Map of docker labelsused in the container definitions settings. | `map(any)` | `{}` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | Memory used in the container definitions settings. | `number` | n/a | yes |
| <a name="input_container_memory_reservation"></a> [container\_memory\_reservation](#input\_container\_memory\_reservation) | Memory reservation used in the container definitions settings. | `number` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port to used in the ECS Service. | `string` | `""` | no |
| <a name="input_container_protocol"></a> [container\_protocol](#input\_container\_protocol) | Container protocol used in the container definitions settings. | `string` | `"tcp"` | no |
| <a name="input_container_secrets"></a> [container\_secrets](#input\_container\_secrets) | List of secret variables used in the container definitions settings. | <pre>list(object({<br>    name      = string<br>    valueFrom = string<br>  }))</pre> | `[]` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to be added to route53 records. | `string` | `null` | no |
| <a name="input_domain_zone_id"></a> [domain\_zone\_id](#input\_domain\_zone\_id) | Route53 zone ID to be used by this module. | `string` | `null` | no |
| <a name="input_ecs_capacity_provider_strategies"></a> [ecs\_capacity\_provider\_strategies](#input\_ecs\_capacity\_provider\_strategies) | Capacity provider strategy to use for the ECS Service. | <pre>list(object({<br>    capacity_provider = string,<br>    weight            = number<br>  }))</pre> | `[]` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS Cluster name to ECS Service deploy. | `string` | n/a | yes |
| <a name="input_ecs_cpu_scale_in_cooldown"></a> [ecs\_cpu\_scale\_in\_cooldown](#input\_ecs\_cpu\_scale\_in\_cooldown) | CPU scale-in cooldown. Amount of time, in seconds, after a scale in activity completes before another scale in activity can start. | `number` | `180` | no |
| <a name="input_ecs_cpu_scale_out_cooldown"></a> [ecs\_cpu\_scale\_out\_cooldown](#input\_ecs\_cpu\_scale\_out\_cooldown) | CPU scale-out cooldown. Amount of time, in seconds, after a scale out activity completes before another scale out activity can start. | `number` | `60` | no |
| <a name="input_ecs_cpu_scale_target_value"></a> [ecs\_cpu\_scale\_target\_value](#input\_ecs\_cpu\_scale\_target\_value) | CPU target value for the metric. | `number` | `80` | no |
| <a name="input_ecs_deployment_maximum_percent"></a> [ecs\_deployment\_maximum\_percent](#input\_ecs\_deployment\_maximum\_percent) | Upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a ECS service during a deployment. | `string` | `"200"` | no |
| <a name="input_ecs_deployment_minimum_healthy_percent"></a> [ecs\_deployment\_minimum\_healthy\_percent](#input\_ecs\_deployment\_minimum\_healthy\_percent) | Lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a ECS service during a deployment. | `string` | `"100"` | no |
| <a name="input_ecs_desired_count"></a> [ecs\_desired\_count](#input\_ecs\_desired\_count) | Number of instances of the task definition to place and keep running. | `number` | n/a | yes |
| <a name="input_ecs_enable_auto_scaling_cpu"></a> [ecs\_enable\_auto\_scaling\_cpu](#input\_ecs\_enable\_auto\_scaling\_cpu) | Enable auto scaling policies based on CPU if set to true. | `bool` | `false` | no |
| <a name="input_ecs_enable_auto_scaling_mem"></a> [ecs\_enable\_auto\_scaling\_mem](#input\_ecs\_enable\_auto\_scaling\_mem) | Enable auto scaling policies based on MEM if set to true. | `bool` | `false` | no |
| <a name="input_ecs_health_check_grace_period_seconds"></a> [ecs\_health\_check\_grace\_period\_seconds](#input\_ecs\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers. | `number` | `0` | no |
| <a name="input_ecs_max_capacity"></a> [ecs\_max\_capacity](#input\_ecs\_max\_capacity) | Max capacity of the ECS Service. | `number` | `1` | no |
| <a name="input_ecs_mem_scale_in_cooldown"></a> [ecs\_mem\_scale\_in\_cooldown](#input\_ecs\_mem\_scale\_in\_cooldown) | Memory scale-in cooldown. Amount of time, in seconds, after a scale in activity completes before another scale in activity can start. | `number` | `180` | no |
| <a name="input_ecs_mem_scale_out_cooldown"></a> [ecs\_mem\_scale\_out\_cooldown](#input\_ecs\_mem\_scale\_out\_cooldown) | Memory scale-out cooldown. Amount of time, in seconds, after a scale out activity completes before another scale out activity can start. | `number` | `60` | no |
| <a name="input_ecs_min_capacity"></a> [ecs\_min\_capacity](#input\_ecs\_min\_capacity) | Min capacity of the ECS Service. | `number` | `1` | no |
| <a name="input_ecs_ordered_placement_strategy"></a> [ecs\_ordered\_placement\_strategy](#input\_ecs\_ordered\_placement\_strategy) | Changes ordered placement strategy of ECS service. | `list(map(string))` | <pre>[<br>  {<br>    "field": "attribute:ecs.availability-zone",<br>    "type": "spread"<br>  }<br>]</pre> | no |
| <a name="input_ecs_scale_mem_target_value"></a> [ecs\_scale\_mem\_target\_value](#input\_ecs\_scale\_mem\_target\_value) | Memory target value for the metric. | `number` | `80` | no |
| <a name="input_ecs_task_network_mode"></a> [ecs\_task\_network\_mode](#input\_ecs\_task\_network\_mode) | The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host. | `string` | `"bridge"` | no |
| <a name="input_ecs_wait_for_steady_state"></a> [ecs\_wait\_for\_steady\_state](#input\_ecs\_wait\_for\_steady\_state) | If true, Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all resources as identifier. | `string` | n/a | yes |
| <a name="input_nlb_listener_load_balancer_arn"></a> [nlb\_listener\_load\_balancer\_arn](#input\_nlb\_listener\_load\_balancer\_arn) | ARN of the network load balancer used by the ECS service. | `string` | `null` | no |
| <a name="input_nlb_listener_port"></a> [nlb\_listener\_port](#input\_nlb\_listener\_port) | Port of the network load balancer used by the ECS service | `number` | `null` | no |
| <a name="input_nlb_listener_protocol"></a> [nlb\_listener\_protocol](#input\_nlb\_listener\_protocol) | Protocol of the network load balancer used by the ECS service. | `string` | `"TCP"` | no |
| <a name="input_nlb_listener_ssl_certificate_arn"></a> [nlb\_listener\_ssl\_certificate\_arn](#input\_nlb\_listener\_ssl\_certificate\_arn) | ARN SSL Certificate of the network load balancer used by the ECS service. | `string` | `null` | no |
| <a name="input_nlb_listener_ssl_policy"></a> [nlb\_listener\_ssl\_policy](#input\_nlb\_listener\_ssl\_policy) | SSL Policy of the network load balancer used by the ECS service. | `string` | `null` | no |
| <a name="input_sg_ingress_cidr_blocks"></a> [sg\_ingress\_cidr\_blocks](#input\_sg\_ingress\_cidr\_blocks) | List of CIDR blocks for the ECS service security group. | `list(string)` | `null` | no |
| <a name="input_sg_ingress_security_group_ids"></a> [sg\_ingress\_security\_group\_ids](#input\_sg\_ingress\_security\_group\_ids) | List of  security groups IDs for the ECS service security group. | `list(string)` | `null` | no |
| <a name="input_sub_domain"></a> [sub\_domain](#input\_sub\_domain) | Sub domain to be added to route53 records. | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of Subnet IDs to be used in the ECS Service if `ecs_task_network_mode` has value set to `awsvpc`. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be added to all resources. | `map(string)` | `{}` | no |
| <a name="input_task_definition_efs_volumes"></a> [task\_definition\_efs\_volumes](#input\_task\_definition\_efs\_volumes) | List of EFS volumes to make available for use on the container\_definitions. Each item should be a map with 3 properties: name, file\_system\_id and root\_directory. | `list(any)` | `[]` | no |
| <a name="input_task_definition_execution_role_arn"></a> [task\_definition\_execution\_role\_arn](#input\_task\_definition\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | `null` | no |
| <a name="input_task_definition_host_volumes"></a> [task\_definition\_host\_volumes](#input\_task\_definition\_host\_volumes) | List of host volumes to make available for use on the container\_definitions. Each item should be an object with 2 properties: name and host\_path. | <pre>list(object({<br>    name      = string<br>    host_path = string<br>  }))</pre> | `[]` | no |
| <a name="input_task_definition_role_arn"></a> [task\_definition\_role\_arn](#input\_task\_definition\_role\_arn) | ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. | `string` | `null` | no |
| <a name="input_tg_deregistration_delay"></a> [tg\_deregistration\_delay](#input\_tg\_deregistration\_delay) | Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 60 seconds. | `string` | `"60"` | no |
| <a name="input_tg_health_check_interval"></a> [tg\_health\_check\_interval](#input\_tg\_health\_check\_interval) | Approximate amount of time, in seconds, between health checks of an individual target. The default value is 5. | `number` | `5` | no |
| <a name="input_tg_health_check_matcher"></a> [tg\_health\_check\_matcher](#input\_tg\_health\_check\_matcher) | Response codes to use when checking for a healthy responses from a target. The default value is 200. | `string` | `"200"` | no |
| <a name="input_tg_health_check_path"></a> [tg\_health\_check\_path](#input\_tg\_health\_check\_path) | Destination for the health check request. The default value is `/`. | `string` | `"/"` | no |
| <a name="input_tg_health_check_timeout"></a> [tg\_health\_check\_timeout](#input\_tg\_health\_check\_timeout) | Amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds. The default value is 3. | `number` | `3` | no |
| <a name="input_tg_healthy_threshold"></a> [tg\_healthy\_threshold](#input\_tg\_healthy\_threshold) | Number of consecutive health check successes required before considering a target healthy. The range is 2-10. The default value is 2. | `number` | `2` | no |
| <a name="input_tg_name"></a> [tg\_name](#input\_tg\_name) | Target Group name, needed because of resource name size limitations. | `string` | `null` | no |
| <a name="input_tg_unhealthy_threshold"></a> [tg\_unhealthy\_threshold](#input\_tg\_unhealthy\_threshold) | Number of consecutive health check failures required before considering a target unhealthy. The range is 2-10. Defaults to 2. | `number` | `2` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to be used in the ECS Service. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_definitions_rendered"></a> [container\_definitions\_rendered](#output\_container\_definitions\_rendered) | Container definitions data rendered. |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | ARN of the ECS service. |
| <a name="output_ecs_service_cluster"></a> [ecs\_service\_cluster](#output\_ecs\_service\_cluster) | Cluster ARN of the ECS service. |
| <a name="output_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#output\_ecs\_service\_desired\_count) | Desired count of the ECS service. |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service. |
| <a name="output_ecs_task_definition_arn"></a> [ecs\_task\_definition\_arn](#output\_ecs\_task\_definition\_arn) | ARN of the ECS task definition. |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | Family of the ECS task definition. |
| <a name="output_ecs_task_definition_revision"></a> [ecs\_task\_definition\_revision](#output\_ecs\_task\_definition\_revision) | Revision of the ECS task definition. |
| <a name="output_route53_alb_fqdn"></a> [route53\_alb\_fqdn](#output\_route53\_alb\_fqdn) | Default fqdn of the Route53. |
| <a name="output_route53_alb_name"></a> [route53\_alb\_name](#output\_route53\_alb\_name) | Default name of the Route53. |
| <a name="output_route53_nlb_fqdn"></a> [route53\_nlb\_fqdn](#output\_route53\_nlb\_fqdn) | NLB fqdn of the Route53. |
| <a name="output_route53_nlb_name"></a> [route53\_nlb\_name](#output\_route53\_nlb\_name) | NLB name of the Route53. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Security group ARN used by the ECS service. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID used by the ECS service. |
| <a name="output_target_group_alb_arn"></a> [target\_group\_alb\_arn](#output\_target\_group\_alb\_arn) | ARN of the ALB target group. |
| <a name="output_target_group_nlb_arn"></a> [target\_group\_nlb\_arn](#output\_target\_group\_nlb\_arn) | ARN of the NLB target group. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
