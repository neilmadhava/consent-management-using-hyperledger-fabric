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

export CONSENT_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/airport.example.com/ca && ls *_sk)
export CONSENT_CA2_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/ccd.example.com/ca && ls *_sk)
export CONSENT_CA3_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/users.example.com/ca && ls *_sk)

docker-compose -f docker-compose-cli2.yaml down
docker-compose -f docker-compose-cli2.yaml up -d orderer.example.com ca0 ca1 ca2 peer0.airport.example.com peer1.airport.example.com peer0.ccd.example.com peer1.ccd.example.com peer0.users.example.com peer1.users.example.com cli

# wait for Hyperledger Fabric to start
# incase of errors when running later commands, issue export 
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
ORDERER_CA=${CONFIG_ROOT}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Create the channel
docker exec cli \
	peer channel create -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

echo "===================== Channel '$CHANNEL_NAME' created ===================== "
echo

orgs="airport ccd users"
DELAY=2
port=7051
sleep $DELAY

# Join peer of all organizations to the channel
for org in $orgs; do
	for peer in 0 1; do
		docker exec \
			-e "CORE_PEER_LOCALMSPID=${org}" \
			-e "CORE_PEER_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
			-e "CORE_PEER_ADDRESS=peer${peer}.${org}.example.com:${port}" \
			-e CORE_PEER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/${org}.example.com/peers/peer${peer}.${org}.example.com/tls/ca.crt \
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
		-e "CORE_PEER_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
		-e "CORE_PEER_ADDRESS=peer0.${org}.example.com:${port}" \
		-e CORE_PEER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/ca.crt \
		cli \
		peer channel update \
			-o orderer.example.com:7050 \
			-c $CHANNEL_NAME \
			-f ./channel-artifacts/${org}anchors.tx \
			--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
	let "port = $port + 2000"
	echo "================= Anchor peers updated for org '$org' on channel '$CHANNEL_NAME' ================= "
done

# install chaincode on peer0.airport, peer0.ccd, peer0.users
port=7051
for org in $orgs; do
	docker exec \
		-e "CORE_PEER_LOCALMSPID=${org}" \
		-e "CORE_PEER_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp" \
		-e "CORE_PEER_ADDRESS=peer0.${org}.example.com:${port}" \
		-e CORE_PEER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/${org}.example.com/peers/peer0.${org}.example.com/tls/ca.crt \
		cli \
		peer chaincode install \
			-n chainv1_3 \
			-v 1.0 \
			-l node \
			-p /opt/gopath/src/github.com/chaincode/chain_person/
	let "port = $port + 2000"
	echo "=============== Chaincode is installed on peer0.${org} =============== "
done

# Instantiating smart contract
echo "Instantiating smart contract on mychannel"
docker exec \
  -e CORE_PEER_LOCALMSPID=airport \
  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
  -e CORE_PEER_ADDRESS=peer0.airport.example.com:7051 \
  -e CORE_PEER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/airport.example.com/peers/peer0.airport.example.com/tls/ca.crt \
  cli \
  peer chaincode instantiate \
    -o orderer.example.com:7050 \
    -C mychannel \
    -n chainv1_3 \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    -l node \
    -v 1.0 \
    -c '{"Args":["init"]}' \
    -P "OR ('airport.member','ccd.member','users.member')" \
    --peerAddresses peer0.airport.example.com:7051 \
    --tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/airport.example.com/peers/peer0.airport.example.com/tls/ca.crt \
    --collections-config /opt/gopath/src/github.com/chaincode/chain_person/collections_config.json
    

sleep 10

echo "Chaincode Instantiated!"

# Invoking Smart Contract
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
#   peer chaincode invoke \
#   	-o orderer.example.com:7050 \
#   	-C mychannel \
#   	-n chainv1_3 \
#   	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
#   	-c '{"function":"initPerson","Args":["user_01","Delhi","Mukunda","31-Jan-2020","8178637565", "card_01", "uid001", "mm@gmail.com", "high"]}' \
#   	--peerAddresses peer0.airport.example.com:7051 \
#   	--peerAddresses peer0.ccd.example.com:9051 \
#   	--peerAddresses peer0.users.example.com:11051 \
#   	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/airport.example.com/peers/peer0.airport.example.com/tls/ca.crt \
#   	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/ccd.example.com/peers/peer0.ccd.example.com/tls/ca.crt \
#   	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/users.example.com/peers/peer0.users.example.com/tls/ca.crt

# Query Ledger for ccd
# docker exec \
#   -e CORE_PEER_LOCALMSPID=ccd \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ccd.example.com/users/Admin@ccd.example.com/msp \
#   cli \
#   peer chaincode query \
#   	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
#   	-C mychannel \
#   	-n chainv1_3 \
#   	-c '{"function":"readPerson","Args":["user_01"]}'

# # Query Ledger for airport and users
# docker exec \
#   -e CORE_PEER_LOCALMSPID=airport \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
#   cli \
#   peer chaincode query \
#   	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
#   	-C mychannel \
#   	-n chainv1_3 \
#   	-c '{"function":"readPrivatePerson","Args":["user_01"]}'


# peer chaincode invoke \
#   	-o orderer.example.com:7050 \
#   	-C mychannel \
#   	-n chainv1_3 \
#   	-c '{"function":"initPerson","Args":["user_02","Bangalore","Basil","03-Feb-2020","9038735239", "card_02", "uid002", "bgp@ymail.com", "low"]}' \
#   	--peerAddresses peer0.airport.example.com:7051 \
#   	--peerAddresses peer0.ccd.example.com:9051 \
#   	--peerAddresses peer0.users.example.com:11051

# docker exec \
#   -e CORE_PEER_LOCALMSPID=users \
#   -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.example.com/users/Admin@users.example.com/msp \
#   cli \
# 	peer chaincode invoke \
# 	  	-o orderer.example.com:7050 \
# 	  	-C mychannel \
# 	  	-n chainv1_3 \
# 	  	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
# 	  	-c '{"function":"revokeConsent","Args":["user_01"]}' \
# 	  	--peerAddresses peer0.airport.example.com:7051 \
# 	  	--peerAddresses peer0.ccd.example.com:9051 \
# 	  	--peerAddresses peer0.users.example.com:11051 \
# 	  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/airport.example.com/peers/peer0.airport.example.com/tls/ca.crt \
# 	  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/ccd.example.com/peers/peer0.ccd.example.com/tls/ca.crt \
# 	  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/users.example.com/peers/peer0.users.example.com/tls/ca.crt



# peer chaincode invoke \
#     -o orderer.example.com:7050 \
#     -C mychannel \
#     -n chainv1_3 \
#     -c '{"function":"deletePerson","Args":["user_02"]}' \
#     --peerAddresses peer0.airport.example.com:7051 \
#     --peerAddresses peer0.users.example.com:11051

# ENV VARIABLES

# for airport
# CORE_PEER_LOCALMSPID=airport
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp

# # for ccd
# CORE_PEER_LOCALMSPID=ccd
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ccd.example.com/users/Admin@ccd.example.com/msp

# # for users
# CORE_PEER_LOCALMSPID=users
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.example.com/users/Admin@users.example.com/msp
