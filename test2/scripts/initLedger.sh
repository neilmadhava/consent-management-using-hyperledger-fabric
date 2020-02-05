#!/bin/bash
# A shell script to read file line by line
 
filename="./scripts/result.txt"
i=0

while read line
do 
    if [ $i == 0 ]
    then 
        userID="\"$line\""
    elif [ $i == 1 ]
    then
        src="\"$line\""
    elif [ $i = 2 ]
    then
        name="\"$line\""
    elif [ $i = 3 ]
    then
        departDate="\"$line\""
    elif [ $i = 4 ]
    then
        phone="\"$line\""
    elif [ $i = 5 ]
    then
        creditCard="\"$line\""
    elif [ $i = 6 ]
    then
        aadhar_id="\"$line\""
    elif [ $i = 7 ]
    then
        email="\"$line\""
    elif [ $i = 8 ]
    then
        consent_type="\"$line\""
    fi

    let "i = $i + 1";
done < $filename

consent="$(echo $consent_type | awk '{print tolower($0)}')";

args="$(echo "$(echo $userID)", "$(echo $src)", "$(echo $name)", "$(echo $departDate)", "$(echo $phone)", "$(echo $creditCard)", "$(echo $aadhar_id)", "$(echo $email)", "$(echo $consent)")"
# echo $args

# Invoking Smart Contract
docker exec \
  -e CORE_PEER_LOCALMSPID=users \
  -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/users.example.com/users/Admin@users.example.com/msp \
  cli \
  peer chaincode invoke \
  	-o orderer.example.com:7050 \
  	-C mychannel \
  	-n chainv1_3 \
  	-c '{"function":"initPerson","Args":['"$(echo $args)"']}' \
  	--peerAddresses peer0.airport.example.com:7051 \
  	--peerAddresses peer0.ccd.example.com:9051 \
  	--peerAddresses peer0.users.example.com:11051