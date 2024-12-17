#!/bin/bash

# load env variables
source .env

# Deploy001_Diamond_Dollar_Governance (deploys Diamond)
forge script migrations/testnet/Deploy001 --rpc-url $RPC_URL --broadcast -vvvv