#!/bin/bash
set -e

ENVIRONMENT="${1:-dev}"
IMAGE_NAME="nginx-https"
IMAGE_TAG="${2:-latest}"

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo "Usage: $0 <dev|test|prod> [tag]"
    exit 1
fi

echo "Building and pushing Docker image for ${ENVIRONMENT}..."

# to get ACR details from terraform
cd "$(dirname "$0")/../env/${ENVIRONMENT}"
ACR_NAME=$(terraform output -raw acr_name)
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)

# login to ACR
az acr login --name "${ACR_NAME}"

# building image
cd "$(dirname "$0")/../docker/nginx"
docker build \
    --platform linux/amd64 \
    -t "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}" \
    -t "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest" \
    .

# pushing to ACR
docker push "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
docker push "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:latest"

echo "Image pushed: ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
