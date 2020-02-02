#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.

set -e
CHANNEL_NAME=mychannel

orgs="airport ccd users"

# install chaincode on peer0.airport, peer0.ccd, peer0.users
port=7051
for org in $orgs; do
	docker exec \
		-e "CORE_PEER_LOCALMSPID=${org}" \
		-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
		-e "CORE_PEER_ADDRESS=peer0.${org}.example.com:${port}" \
		cli peer chaincode install \
			-n chainp1_8 \
			-v 1.0 \
			-l node \
			-p /opt/gopath/src/github.com/chaincode/chain_person01/
	let "port = $port + 2000"
	echo "=============== Chaincode is installed on peer0.${org} =============== "
done

# Instantiating smart contract
echo "Instantiating smart contract on mychannel"
docker exec \
  -e CORE_PEER_LOCALMSPID=airport \
  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
  cli \
  peer chaincode instantiate \
    -o orderer.example.com:7050 \
    -C mychannel \
    -n chainp1_8 \
    -l node \
    -v 1.0 \
    -c '{"Args":["init"]}' \
    -P "OR ('airport.member','ccd.member','users.member')" \
    --peerAddresses peer0.airport.example.com:7051 \
    --collections-config /opt/gopath/src/github.com/chaincode/chain_person01/collections_config.json

sleep 10
echo "Chaincode Instantiated Successfully!"
