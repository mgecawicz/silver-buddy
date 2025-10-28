#!/bin/bash
set -e

cd ../environment/

export TF_LOG="TRACE"
export TF_LOG_PATH="./terraform.log"

# Source environment variables
set -a
source .env
set +a

terraform init -upgrade
terraform plan -parallelism=5
terraform apply