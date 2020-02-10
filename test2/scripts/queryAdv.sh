choice="$1"
org="$2"
userID="$3"
CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
ORDERER_CA=${CONFIG_ROOT}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Query Data
if [ $choice -eq 1 ]
then
	if [ \( "$org" = "airport" \) -o \( "$org" = "users" \) ]
	then
		docker exec \
		  -e CORE_PEER_LOCALMSPID=$org \
		  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp \
		  cli \
		  peer chaincode query \
		  	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
		  	-C mychannel \
		  	-n chainv1_3 \
		  	-c '{"function":"readPrivatePerson","Args":['"\"$userID\""']}' > ./scripts/queryResults.json
	fi
	if [ $org = "ccd" ]
	then
		docker exec \
		  -e CORE_PEER_LOCALMSPID=$org \
		  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp \
		  cli \
		  peer chaincode query \
		  	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
		  	-C mychannel \
		  	-n chainv1_3 \
		  	-c '{"function":"readPerson","Args":['"\"$userID\""']}' > ./scripts/queryResults.json
	fi
fi

# Revoke Consent
if [ $choice -eq 2 ]
then
	docker exec \
	  -e CORE_PEER_LOCALMSPID=$org \
	  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp \
	  cli \
		peer chaincode invoke \
		  	-o orderer.example.com:7050 \
		  	-C mychannel \
		  	-n chainv1_3 \
		  	--tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
		  	-c '{"function":"revokeConsent","Args":['"\"$userID\""']}' \
		  	--peerAddresses peer0.airport.example.com:7051 \
		  	--peerAddresses peer0.ccd.example.com:9051 \
		  	--peerAddresses peer0.users.example.com:11051 \
		  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/airport.example.com/peers/peer0.airport.example.com/tls/ca.crt \
		  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/ccd.example.com/peers/peer0.ccd.example.com/tls/ca.crt \
		  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/users.example.com/peers/peer0.users.example.com/tls/ca.crt
fi

# Purge Data
if [ $choice -eq 3 ]
then
	docker exec \
	  -e CORE_PEER_LOCALMSPID=$org \
	  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp \
	  cli \
		  peer chaincode invoke \
		    -o orderer.example.com:7050 \
		    -C mychannel \
		    -n chainv1_3 \
		    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
		    -c '{"function":"deletePerson","Args":['"\"$userID\""']}' \
		    --peerAddresses peer0.airport.example.com:7051 \
		  	--peerAddresses peer0.users.example.com:11051 \
		  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/airport.example.com/peers/peer0.airport.example.com/tls/ca.crt \
		  	--tlsRootCertFiles ${CONFIG_ROOT}/crypto/peerOrganizations/users.example.com/peers/peer0.users.example.com/tls/ca.crt
fi


