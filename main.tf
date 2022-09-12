provider "aws"{
    access_key=""
    secret_key=""
    region="ap-northeast-1"
    profile="mfa"
}
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}