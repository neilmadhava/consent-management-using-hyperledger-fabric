#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./scripts/ccp-template1.json 
}

function yaml_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./scripts/ccp-template1.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

ORG=airport
P0PORT=7051
P1PORT=8051
CAPORT=7054
PEERPEM=crypto-config/peerOrganizations/airport.example.com/tlsca/tlsca.airport.example.com-cert.pem
CAPEM=crypto-config/peerOrganizations/airport.example.com/ca/ca.airport.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-airport.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-airport.yaml

ORG=ccd
P0PORT=9051
P1PORT=10051
CAPORT=8054
PEERPEM=crypto-config/peerOrganizations/ccd.example.com/tlsca/tlsca.ccd.example.com-cert.pem
CAPEM=crypto-config/peerOrganizations/ccd.example.com/ca/ca.ccd.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-ccd.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-ccd.yaml

ORG=users
P0PORT=11051
P1PORT=12051
CAPORT=9054
PEERPEM=crypto-config/peerOrganizations/users.example.com/tlsca/tlsca.users.example.com-cert.pem
CAPEM=crypto-config/peerOrganizations/users.example.com/ca/ca.users.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-users.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-users.yaml

ORG=mcd
P0PORT=13051
P1PORT=14051
CAPORT=10054
PEERPEM=crypto-config/peerOrganizations/mcd.example.com/tlsca/tlsca.mcd.example.com-cert.pem
CAPEM=crypto-config/peerOrganizations/mcd.example.com/ca/ca.mcd.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-mcd.json
echo "$(yaml_ccp $ORG $P0PORT $P1PORT $CAPORT $PEERPEM $CAPEM)" > ./scripts/connection-mcd.yaml
