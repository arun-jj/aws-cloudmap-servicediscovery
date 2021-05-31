#!/bin/bash

set -ex

DIR="$( cd "$( dirname ${BASH_SOURCE[0]} )" >/dev/null && pwd )"

ACCOUNT_ID=$(aws --profile "${AWS_PROFILE}" --region "${AWS_REGION}" sts get-caller-identity | jq -r '.Account')

ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# build order image
echo 'Building order service image'
image=$(docker build -f ${DIR}/../containers/order/Dockerfile -t order ${DIR}/../containers)

# build fulfillment image
echo 'Building fulfillment service image'
image=$(docker build -f ${DIR}/../containers/fulfillment/Dockerfile -t fulfillment ${DIR}/../containers)

aws --profile "${AWS_PROFILE}" --region "${AWS_REGION}" ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_URL}"

echo 'Pushing order service image'
tag=$(docker tag order:latest ${ECR_URL}/order:latest)
push=$(docker push ${ECR_URL}/order:latest)

echo 'Pushing fulfillment service image'
tag=$(docker tag fulfillment:latest ${ECR_URL}/fulfillment:latest)
push=$(docker push ${ECR_URL}/fulfillment:latest)
