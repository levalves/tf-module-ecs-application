provider "aws" {
  region = var.aws_region
  alias  = "dst"

  assume_role {
    role_arn = var.aws_role
  }
}
