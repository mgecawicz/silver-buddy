#!/bin/bash
set -e

cd ../environment/

export TF_LOG="TRACE"
export TF_LOG_PATH="./terraform.log"

# Clean up
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.log

# Source environment variables
set -a
source .env
set +a

# IMPORTANT: Force ARM64 architecture for Apple Silicon
rm -rf ~/.terraform.d/plugin-cache  # Clear any cached AMD64 versions

terraform init -reconfigure
# terraform plan -parallelism=5