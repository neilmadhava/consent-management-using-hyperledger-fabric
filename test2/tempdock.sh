#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e
CHANNEL_NAME=mychannel
# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# LANGUAGE=${1:-"node"}
# if [ "$LANGUAGE" = "node" -o "$LANGUAGE" = "NODE" ]; then
#     cd ./chaincode/testHigh/
#     yarn
#     yarn run clean
#     yarn run build
# fi


# clean the keystore
rm -rf ./hfc-key-store
cd "$DIR"
docker-compose -f docker-compose-cli.yaml down
docker-compose -f docker-compose-cli.yaml up -d orderer.example.com peer0.airport.example.com peer1.airport.example.com peer0.ccd.example.com peer1.ccd.example.com peer0.users.example.com peer1.users.example.com couchdb cli

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export 
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec cli \
	peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx

echo "===================== Channel '$CHANNEL_NAME' created ===================== "
echo

orgs="airport ccd users"
DELAY=2
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

# Update anchor peers
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
			-n chainp \
			-v 1.0 \
			-l node \
			-p /opt/gopath/src/github.com/chaincode/chain_person/
	let "port = $port + 2000"
	echo "=============== Chaincode is installed on peer0.${org} =============== "
done

# Instantiating smart contract
# echo "Instantiating smart contract on mychannel"
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
  # peer chaincode instantiate \
  #   -o orderer.example.com:7050 \
  #   -C mychannel \
  #   -n chainp \
  #   -l node \
  #   -v 1.0 \
  #   -c '{"Args":["init"]}' \
  #   -P "OR ('airport.member','ccd.member','users.member')" \
  #   --peerAddresses peer0.airport.example.com:7051 \
  #   --collections-config /opt/gopath/src/github.com/chaincode/chain_person/collections_config.json
    

# sleep 10

# echo "Chaincode Instantiated Bitch! Part Time!"

# # Invoking Smart Contract
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
  # peer chaincode invoke \
  # 	-o orderer.example.com:7050 \
  # 	-C mychannel \
  # 	-n chainp \
  # 	-c '{"function":"initPerson","Args":["uid_01","mukunda","mm@gmail.com","8178637565"]}' \
  # 	--peerAddresses peer0.airport.example.com:7051 \
  #   --peerAddresses peer0.ccd.example.com:9051 \
  #   --peerAddresses peer0.users.example.com:11051

# # Query Ledger
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
  # peer chaincode query \
  # 	-C mychannel \
  # 	-n chainp \
  # 	-c '{"function":"readPerson","Args":["uid_01"]}'