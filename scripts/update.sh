#!/bin/bash
set -e

cd ../api/cron/update_silver_spot

echo "Building requests Lambda layer..."


pip install requests -t ./lambda_layer/python

echo "Creating layer zip file..."

# Zip the layer
cd lambda_layer
zip -r ../requests_layer.zip .
cd ..

# Clean up the build directory
rm -rf lambda_layer

cd ../../../environment/

export TF_LOG="TRACE"
export TF_LOG_PATH="./terraform.log"

# Source environment variables
set -a
source .env
set +a

terraform init -upgrade
terraform plan -parallelism=5
terraform apply

rm -rf ../api/cron/update_silver_spot/request_layer.zip
m -f ../api/health-check-code.zip
rm -f ../api/update_silver_spot.zip