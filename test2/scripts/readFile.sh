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

./scripts/initLedger.sh $userID $src $name $departDate $phone $creditCard $aadhar_id $email $consent_type