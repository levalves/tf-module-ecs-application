module "ecs_service" {
  source = "../../"

  name            = module.app_label.id
  tg_name         = module.app_label.id
  sub_domain      = "stg"
  region          = "us-east-1"
  vpc_id          = data.aws_vpc.this.id
  subnets         = ["subnet-05ce818f362fd6149", "subnet-0129de3f1907896b1"]
  cluster_name    = module.ecs.name
  ecs_cluster_arn = module.ecs.this_ecs_cluster_arn

  deregistration_delay  = 0
  health_check_path     = "/healthcheck"
  health_check_matcher  = "200"
  health_check_interval = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 2
  health_check_timeout  = 3

  desired_count         = 1
  max_capacity          = 2
  container_port        = 8080
  container_definitions = data.template_file.container_definitions.rendered

  alb_listener_arn           = module.loadbalancer_listener_https.arn_https
  alb_listener_rule_priority = 99

  alb_dns_name   = module.application_loadbalancer.dns_name
  alb_zone_id    = module.application_loadbalancer.zone_id
  domain_zone_id = "ZT99DT4VMP2W8"

  nlb_listner_settings = {
    load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:930756472606:loadbalancer/net/zp-staging-nlb-shared/c617c1b7a125b80a",
    port              = 1025,
    ssl = {
      policy          = "ELBSecurityPolicy-2016-08"
      certificate_arn = data.aws_acm_certificate.cert.arn
    }
  }

  tags = module.app_label.tags
}

data "template_file" "container_definitions" {
  template = file("${path.module}/container_definitions.tpl")

  vars = {
    name  = module.app_label.id
    image = "${aws_ecr_repository.ecr.repository_url}:1.0.1"
  }
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::930756472606:role/CrossAccount-Payments_NonProd"
  }
}

resource "random_string" "record_name" {
  length  = 3
  upper   = false
  special = false
}

data "aws_vpc" "this" {
  tags = {
    Name = "payment-vpc-staging"
  }
}

data "aws_acm_certificate" "cert" {
  domain      = "*.stg.zoop.tech"
  statuses    = ["ISSUED"]
  most_recent = true
}

module "alb_label" {
  source = "git@github.com:getzoop/tf-module-label.git?ref=v2"

  application        = "test-api-${random_string.record_name.result}"
  product            = "test-api"
  namespace          = "alb"
  environment        = "stg"
  business_owner     = "infrastructure"
  organization_owner = "cloud-engineering"
}

module "app_label" {
  source = "git@github.com:getzoop/tf-module-label.git?ref=v2"

  application        = "test-api-${random_string.record_name.result}"
  product            = "test-api"
  namespace          = ""
  environment        = "stg"
  business_owner     = "infrastructure"
  organization_owner = "cloud-engineering"
}

module "ecs_label" {
  source = "git@github.com:getzoop/tf-module-label.git?ref=v2"

  application        = "test-api-${random_string.record_name.result}"
  product            = "test-api"
  namespace          = "ecs"
  environment        = "stg"
  business_owner     = "infrastructure"
  organization_owner = "cloud-engineering"
}

module "ecr_label" {
  source = "git@github.com:getzoop/tf-module-label.git?ref=v2"

  application        = "test-api-${random_string.record_name.result}"
  product            = "test-api"
  namespace          = "ecr"
  environment        = "stg"
  business_owner     = "infrastructure"
  organization_owner = "cloud-engineering"
}


resource "aws_security_group" "ecs" {
  name        = module.ecs_label.id
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }
  tags = module.ecs_label.tags
}

module "ecs" {
  source = "git@github.com:getzoop/tf-module-ecs-cluster.git?ref=v2"

  name = module.ecs_label.id

  vpc_zone_identifier    = ["subnet-05ce818f362fd6149", "subnet-0129de3f1907896b1"]
  vpc_security_group_ids = [aws_security_group.ecs.id]

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  on_demand_percentage_above_base_capacity = 0

  instance_type         = "t3a.small"
  ebs_volume_size       = 30
  protect_from_scale_in = false
}

resource "aws_security_group" "alb_sg" {
  name        = module.alb_label.id
  description = "Allow inbound/outbound traffic."
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.116/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = module.alb_label.tags
}

module "application_loadbalancer" {
  source          = "git@github.com:getzoop/tf-module-alb.git?ref=v1"
  name            = module.alb_label.id
  internal        = true
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = ["subnet-05ce818f362fd6149", "subnet-0129de3f1907896b1"]

  enable_deletion_protection = false
  idle_timeout               = 300

  tags = module.alb_label.tags
}

module "loadbalancer_listener_https" {
  source            = "git@github.com:getzoop/tf-module-alb-listener.git?ref=v2"
  load_balancer_arn = module.application_loadbalancer.arn
  target_group_arn  = ""
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.cert.arn
  action_type       = "fixed-response"
  content_type      = "text/plain"
  message_body      = "Application not found"
  status_code       = "404"
}

resource "aws_ecr_repository" "ecr" {
  name                 = "test-api"
  image_tag_mutability = "IMMUTABLE"

  tags = module.ecr_label.tags
}

output "alb_fqdn" {
  description = "Application Load Balancer FQDN"
  value       = module.ecs_service.route53_fqdn
}

output "nlb_fqdn" {
  description = "Network Load Balancer FQDN"
  value       = module.ecs_service.route53_nlb
}

output "ecs_cluster" {
  description = "ECS Cluster Name"
  value       = module.ecs.name
}
