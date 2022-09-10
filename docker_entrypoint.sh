#!/bin/sh

echo "AMBOSS_HEALTH_CHECK=true" >> .env
# Display current installed version and help
echo "Balance of Satoshis - Version: "
bos --version
echo "Starting LNDBoss..."
yarn start:prod
