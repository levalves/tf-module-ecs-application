## API Gateway integration via NLB

This example comes with a test application that will be uploaded to ECR.

It adds a listener to a shared NLB, that can be used to integrate AWS Api Gateway using VPCLINK + NLB.

Deploys to Pagzoop nonProd AWS account (`930756472606`).

## Usage

- Build and push test application container, then deploys infrastructure:

```bash
./build.sh deploy
```
- Builds the container:
```bash
./build.sh docker-build
```
- Pushes the container to ECR:
```bash
./build.sh docker-push
```
- Shows terraform plan:
```bash
./build.sh testplan
```
- Shows terraform destroy plan:
```bash
./build.sh destroy-testplan
```
- Run terraform destroy:
```bash
./build.sh destroy-apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3 |
| null | ~> 3 |
| random | ~> 3 |
| template | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3 |
| random | ~> 3 |
| template | ~> 2 |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| alb\_fqdn | Application Load Balancer FQDN |
| ecs\_cluster | ECS Cluster Name |
| nlb\_fqdn | Network Load Balancer FQDN |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
