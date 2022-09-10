#!/bin/sh

set -ea 

echo "AMBOSS_HEALTH_CHECK=true" >> .env
mkdir -p /root/.bos/embassy
chmod -R a+x /root/.bos
mkdir -p /root/.bosgui/start9
chmod -R a+x /root/.bosgui
touch /root/.bosgui/config.json
touch /root/.bosgui/start9/credentials.json 

echo '{
    "cert_path": "/home/node/.lnd/tls.cert",
    "macaroon_path": "/home/node/.lnd/admin.macaroon",
    "socket": "lnd.embassy:10009"
}' >> /root/.bosgui/start9/credentials.json

echo '{"default_saved_node":"start9"}' >> /root/.bosgui/config.json

# Display current installed version and help
echo "Balance of Satoshis - Version: "
bos --version
echo "Starting LNDBoss..."
yarn start:prod
