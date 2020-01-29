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


# install chaincode on peer0.airport, peer0.ccd, peer0.users
port=7051
for org in $orgs; do
	docker exec \
		-e "CORE_PEER_LOCALMSPID=${org}" \
		-e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
		-e "CORE_PEER_ADDRESS=peer0.${org}.example.com:${port}" \
		cli peer chaincode install \
			-n testcontracthighlevel \
			-v 1.0 \
			-l node \
			-p /opt/gopath/src/github.com/chaincode/testContractHighLevel/
	let "port = $port + 2000"
	echo "=============== Chaincode is installed on peer0.${org} =============== "
done

# Instantiating smart contract
echo "Instantiating smart contract on mychannel"
docker exec \
  -e "CORE_PEER_LOCALMSPID=airport" \
  -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp" \
  cli \
  peer chaincode instantiate \
    -o orderer.example.com:7050 \
    -C mychannel \
    -n testcontracthighlevel \
    -l node \
    -v 1.0 \
    -c '{"Args":[]}' \
    -P "AND('airport.member','ccd.member','users.member')" \
    --peerAddresses peer0.airport.example.com:7051

echo "Waiting for instantiation request to be committed ..."
sleep 10


# # Instantiating smart contract
# echo "Instantiating smart contract on mychannel"
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
#   peer chaincode instantiate \
#     -o orderer.example.com:7050 \
#     -C mychannel \
#     -n testcontract \
#     -l node \
#     -v 1.0 \
#     -c '{"Args":[]}' \
#     -P "AND('airport.member','ccd.member','users.member')" \
#     --peerAddresses peer0.airport.example.com:7051

# echo "Waiting for instantiation request to be committed ..."
# sleep 10

# echo "Submitting initLedger transaction to smart contract on mychannel"
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
#   peer chaincode invoke \
#     -o orderer.example.com:7050 \
#     -C mychannel \
#     -n testcontract \
#     -c '{"function":"initLedger","Args":[]}' \
#     --waitForEvent \
#     --peerAddresses peer0.airport.example.com:7051 \
#     --peerAddresses peer0.ccd.example.com:9051 \
#     --peerAddresses peer0.users.example.com:11051


# # Querying Ledger
# echo "Querying smart contract on mychannel"
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
#   peer chaincode query -C mychannel -n testcontract -c '{"Args":["queryAllPersons"]}'

# peer chaincode install -n testcontract -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/testContractHighLevel/

# CORE_PEER_LOCALMSPID=users
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.example.com/users/Admin@users.example.com/msp
# CORE_PEER_ADDRESS=peer0.users.example.com:11051

# peer chaincode instantiate \
#     -o orderer.example.com:7050 \
#     -C mychannel \
#     -n testcontract \
#     -l node \
#     -v 1.0 \
#     -c '{"Args":[]}' \
#     -P "AND('airport.member','ccd.member','users.member')" \
#     --peerAddresses peer0.airport.example.com:7051 \
#     --collections-config /opt/gopath/src/github.com/chaincode/testContractHighLevel/collections_config.json