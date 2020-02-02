userID="$1"
src="$2"
name="$3"
departDate="$4"
phone="$5"
creditCard="$6"
aadhar_id="$7"
email="$8"
consent_type="$9"

echo $userID
echo $src

# Invoking Smart Contract
docker exec \
  -e CORE_PEER_LOCALMSPID=airport \
  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/airport.example.com/users/Admin@airport.example.com/msp \
  cli \
  peer chaincode invoke \
  	-o orderer.example.com:7050 \
  	-C mychannel \
  	-n chainp1_8 \
  	-c '{"function":"initPerson","Args":[$userID, $src, $name, $departDate, $phone , $creditCard, $aadhar_id, $email, $consent_type]}' \
  	--peerAddresses peer0.airport.example.com:7051 \
  	--peerAddresses peer0.ccd.example.com:9051 \
  	--peerAddresses peer0.users.example.com:11051
