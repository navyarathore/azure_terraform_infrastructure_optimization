#!/bin/bash
set -e

# config
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstateazuresa"
CONTAINER_NAME="tfstate"
LOCATION="eastasia"

echo "Creating Terraform backend storage."

# create rg
az group create \
    --name "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --output none

# create storage account
az storage account create \
    --name "${STORAGE_ACCOUNT}" \
    --resource-group "${RESOURCE_GROUP}" \
    --location "${LOCATION}" \
    --sku Standard_LRS \
    --encryption-services blob \
    --https-only true \
    --min-tls-version TLS1_2 \
    --output none

# to get the storage account key
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "${RESOURCE_GROUP}" \
    --account-name "${STORAGE_ACCOUNT}" \
    --query '[0].value' -o tsv)

# for creating a blob container
az storage container create \
    --name "${CONTAINER_NAME}" \
    --account-name "${STORAGE_ACCOUNT}" \
    --account-key "${ACCOUNT_KEY}" \
    --output none

# to enable versioning
az storage account blob-service-properties update \
    --resource-group "${RESOURCE_GROUP}" \
    --account-name "${STORAGE_ACCOUNT}" \
    --enable-versioning true \
    --output none

echo "Backend storage created: ${STORAGE_ACCOUNT}/${CONTAINER_NAME}"
