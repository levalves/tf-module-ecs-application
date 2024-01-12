set -eo pipefail
set +x

if [ ! -d "$PWD/build-tools" ]; then
  git clone --single-branch --branch v3 git@github.com:getzoop/build-tools.git "$PWD/build-tools"
fi
__BUILD_TOOLS_PATH="./build-tools"

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/shell_overrides.sh"
source "$__BUILD_TOOLS_PATH/scripts/s3_artifacts.sh"
source "$__BUILD_TOOLS_PATH/scripts/docker.sh"

# SET APP_NAME
APP_NAME=test-api

# SET DEFAULT AWS ACCOUNT ID
AWS_ACCOUNT_ID=930756472606

# SET APP_VERSION
APP_VERSION="1.0.2"
f_log "APP_VERSION is set to $APP_VERSION"

# AWS SETUP
f_set_aws_role(){
  ROLE="arn:aws:iam::930756472606:role/CrossAccount-Payments_NonProd"
  AWS_ACCOUNT="$(echo $ROLE | cut -d \: -f5)"
}

# SET REGION
f_set_aws_region() {
  REGION="us-east-1"
}

# SET REPO AND IMAGE TAG
f_set_image_tag(){
  f_set_aws_region
  REPO_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$APP_NAME"
  IMAGE_TAG="$REPO_NAME:$APP_VERSION"
}

f_create_ecr() {
  terraform init
  terraform apply -target aws_ecr_repository.ecr -auto-approve
}

f_build_testplan() {
  terraform init
  terraform plan
}

f_apply() {  
  terraform apply -auto-approve
}

f_destroy_testplan() {  
  terraform plan --destroy
}

f_destroy_apply() {
  terraform destroy -auto-approve
}

f_docker_build_image() {
  f_set_image_tag
  f_set_aws_role
  build_image "${PWD}/Dockerfile" $IMAGE_TAG $REGION $ROLE
}

f_docker_push_image() {
  f_set_image_tag
  f_set_aws_role
  push_image $IMAGE_TAG $REGION $ROLE
}

case "$1" in
  docker-build)
    f_docker_build_image
  ;;

  docker-push)
    f_docker_push_image
  ;;

  testplan)
    f_build_testplan
  ;;

  deploy)
    f_create_ecr
    f_docker_build_image
    f_docker_push_image
    f_apply
  ;;

  destroy-testplan)
    f_destroy_testplan
  ;;

  destroy-apply)
    f_destroy_apply
  ;;

  *)
    echo "usage: build.sh docker-build|docker-push|testplan|deploy|destroy-testplan|destroy-apply"
    exit 0
  ;;

esac