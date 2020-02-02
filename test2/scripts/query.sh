choice="$1"
org="$2"
userID="$3"

if [ $choice -eq 1 ]
then
	docker exec \
	  -e CORE_PEER_LOCALMSPID=$org \
	  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp \
	  cli \
	  peer chaincode query \
	  	-C mychannel \
	  	-n chainp1_8 \
	  	-c '{"function":"readPerson","Args":['"\"$userID\""']}'
fi

if [ $choice -eq 2 ]
then
	docker exec \
	  -e CORE_PEER_LOCALMSPID=$org \
	  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.example.com/users/Admin@${org}.example.com/msp \
	  cli \
	  peer chaincode query \
	  	-C mychannel \
	  	-n chainp1_8 \
	  	-c '{"function":"readPrivatePerson","Args":['"\"$userID\""']}'
fi