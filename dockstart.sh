#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e
CHANNEL_NAME=mychannel

# clean the keystore
rm -rf ./hfc-key-store
docker-compose -f docker-compose-cli.yaml down
docker-compose -f docker-compose-cli.yaml up -d orderer.example.com peer0.airport.example.com peer1.airport.example.com peer0.ccd.example.com peer1.ccd.example.com peer0.users.example.com peer1.users.example.com cli

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export 
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
echo Create Channel
docker exec cli \
		peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx\
		 # --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo "===================== Channel '$CHANNEL_NAME' created ===================== "
echo

orgs="airport ccd users"
DELAY=5
port=7051

# Join peer of all organizations to the channel
for org in $orgs; do
	for peer in 0 1; do
		docker exec \
			-e "CORE_PEER_LOCALMSPID=${org}" \
			-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
			-e "CORE_PEER_ADDRESS=peer${peer}.${org}.example.com:${port}" \
			cli peer channel join -b mychannel.block
		let "port = $port + 1000";
		echo "=================== peer${peer}.${org} joined channel '$CHANNEL_NAME' =================== "
		sleep $DELAY
		echo
	done
done

port=7051
for org in $orgs; do
	docker exec \
	-e "CORE_PEER_LOCALMSPID=${org}" \
	-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
	-e "CORE_PEER_ADDRESS=peer0.${org}.example.com:${port}" \
	cli peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${org}anchors.tx
	let "port = $port + 2000"
	echo "================= Anchor peers updated for org '$org' on channel '$CHANNEL_NAME' ================= "
done

