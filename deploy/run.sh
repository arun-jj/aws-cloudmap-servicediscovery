#!/bin/bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

ACCOUNT_ID=$(aws --profile "${AWS_PROFILE}" --region "${AWS_REGION}" sts get-caller-identity | jq -r '.Account')

ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# deploy VPC
aws --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
    cloudformation deploy \
    --stack-name "${STACK_ROOT_NAME}-vpc" \
    --capabilities CAPABILITY_IAM \
    --template-file "${DIR}/../CFN/vpc.yaml" \
    --parameter-overrides \
    VPCName="${STACK_ROOT_NAME}-vpc"


# deploy ECS
aws --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
    cloudformation deploy \
    --stack-name "${STACK_ROOT_NAME}-ecs" \
    --capabilities CAPABILITY_IAM \
    --template-file "${DIR}/../CFN/ecs.yaml"


# deploy Services
aws --profile "${AWS_PROFILE}" --region "${AWS_REGION}" \
    cloudformation deploy \
    --stack-name "${STACK_ROOT_NAME}-services" \
    --capabilities CAPABILITY_IAM \
    --template-file "${DIR}/../CFN/services.yaml" \
    --parameter-overrides \
    ECSClusterStackName="${STACK_ROOT_NAME}-ecs" \
    OrderSvcImage="${ECR_URL}/order:latest" \
    FulfillmentSvcImage="${ECR_URL}/fulfillment:latest" \
    VPCStack="${STACK_ROOT_NAME}-vpc"
