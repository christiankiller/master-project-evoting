#!/bin/bash

########################################
# relative directories
########################################
readonly name=$(basename $0)
readonly dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly parentDir="$(dirname "$dir")"

# For now, the mode is automatically "production", as this script uses docker
# maybe take user input later once local dev works
mode=production
echo "The mode is: $mode"

# the config file with all IPs and ports
globalConfig=$parentDir/system.json

###########################################
# Cleanup
###########################################
rm -rf $dir/backend/mp-crypto
rm -f $dir/.env

########################################
# mp-crypto library
#######################################
cryptoPath=$parentDir/crypto
cp -r $cryptoPath $dir/backend/mp-crypto
rm -rf $dir/backend/mp-crypto/node_modules
rm -rf $dir/backend/mp-crypto/dist

###########################################
# ENV variables
###########################################
# - Voting Authority Backend PORT (the port stays the same, in dev and prod mode) 
VOTING_AUTH_BACKEND_PORT=$(cat $globalConfig | jq .services.voting_authority_backend.port)
# - Voting Authority Backend IP (either 172.1.1.XXX or localhost)
VOTING_AUTH_BACKEND_IP=$(cat $globalConfig | jq .services.voting_authority_backend.ip.$mode | tr -d \")
# - Voting Authority Frontend PORT (the port stays the same, in dev and prod mode)
VOTING_AUTH_FRONTEND_PORT=$(cat $globalConfig | jq .services.voting_authority_frontend.port)
# - Voting Authority Frontend IP (either 172.1.1.XXX or localhost)
VOTING_AUTH_FRONTEND_IP=$(cat $globalConfig | jq .services.voting_authority_frontend.ip.$mode | tr -d \")
# - POA Blockchain Main RPC PORT (the port stays the same, in dev and prod mode)
PARITY_NODE_PORT=$(cat $globalConfig | jq .services.sealer_1_parity.port)
# - POA Blockchain Main RPC IP (either 172.1.1.XXX or localhost)
PARITY_NODE_IP=$(cat $globalConfig | jq .services.sealer_1_parity.ip.$mode | tr -d \")
# - Specify NODE_ENV
NODE_ENV=$mode

###########################################
# write ENV variables into .env
###########################################
echo VOTING_AUTH_BACKEND_PORT=$VOTING_AUTH_BACKEND_PORT >> $dir/.env
echo VOTING_AUTH_BACKEND_IP=$VOTING_AUTH_BACKEND_IP >> $dir/.env
echo VOTING_AUTH_FRONTEND_PORT=$VOTING_AUTH_FRONTEND_PORT >> $dir/.env
echo VOTING_AUTH_FRONTEND_IP=$VOTING_AUTH_FRONTEND_IP >> $dir/.env
echo PARITY_NODE_PORT=$PARITY_NODE_PORT >> $dir/.env
echo PARITY_NODE_IP=$PARITY_NODE_IP >> $dir/.env
echo NODE_ENV=$NODE_ENV >> $dir/.env

###########################################
# docker network
# - make sure the network exists
# - the script will create it if it does not
###########################################
network_name=$(cat $globalConfig | jq .network.name)
$parentDir/docker-network.sh $network_name

###########################################
# >> decide here somehow if docker-compose 
# >> or just simple npm run serve:dev
###########################################
# - start docker containers
docker-compose -p vote-auth -f docker-compose.yml up --build --detach
rm -f $dir/.env