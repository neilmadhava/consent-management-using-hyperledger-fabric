/*
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
*/

'use strict';
const shim = require('fabric-shim');
const util = require('util');

let Chaincode = class {
  async Init(stub) {
    let ret = stub.getFunctionAndParameters();
    console.info(ret);
    console.info('=========== Instantiated Marbles Chaincode ===========');
    return shim.success();
  }

  async Invoke(stub) {
    console.info('Transaction ID: ' + stub.getTxID());
    console.info(util.format('Args: %j', stub.getArgs()));

    let ret = stub.getFunctionAndParameters();
    console.info(ret);

    let method = this[ret.fcn];
    if (!method) {
      console.log('no function of name:' + ret.fcn + ' found');
      throw new Error('Received unknown function ' + ret.fcn + ' invocation');
    }
    try {
      let payload = await method(stub, ret.params, this);
      return shim.success(payload);
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }

  // ===============================================
  // initPerson - create a new person
  // ===============================================
  async initPerson(stub, args, thisClass) {
    if (args.length != 9) {
      throw new Error('Incorrect number of arguments. Expecting 9');
    }
    // ==== Input sanitation ====
    console.info('--- start init person ---')
    if (args[0].lenth <= 0) {
      throw new Error('1st argument must be a non-empty string');
    }
    if (args[1].lenth <= 0) {
      throw new Error('2nd argument must be a non-empty string');
    }
    if (args[2].lenth <= 0) {
      throw new Error('3rd argument must be a non-empty string');
    }
    if (args[3].lenth <= 0) {
      throw new Error('4th argument must be a non-empty string');
    }
    if (args[4].lenth <= 0) {
      throw new Error('5th argument must be a non-empty string');
    }
    if (args[5].lenth <= 0) {
      throw new Error('6th argument must be a non-empty string');
    }
    if (args[6].lenth <= 0) {
      throw new Error('7th argument must be a non-empty string');
    }
    if (args[7].lenth <= 0) {
      throw new Error('8th argument must be a non-empty string');
    }
    if (args[8].lenth <= 0) {
      throw new Error('9th argument must be a non-empty string');
    }
    if (args[8].toLowerCase() !== "low" && args[8].toLowerCase() !== "high" && args[8].toLowerCase() !== "medium"){
      throw new Error('9th argument must be LOW / MEDIUM / HIGH');
    }

    let userID = args[0];
    let source = args[1];
    let name = args[2];
    let departDate = args[3];
    let phone = args[4];
    let creditCard = args[5];
    let aadhar_id = args[6];
    let email = args[7].toLowerCase();
    let consent_type = args[8].toLowerCase();

    // ==== Check if person already exists ====
    let personState = await stub.getPrivateData("testCollection", userID);
    if (personState.toString()) {
      throw new Error('This person already exists: ' + userID);
    }

    // CREATING DATA DEFINITION FOR PUBLIC AND PRIVATE DATA

    let person = {};
    let personPrivate = {};

    if (consent_type === "low"){
      // ==== Create person object and marshal to JSON ====
      person.userID = userID;
      person.source = source;
      person.departDate = departDate;
      person.consent_type = consent_type;
      
      // ==== Create personPrivate object and marshal to JSON ====
      personPrivate.name = name;
      personPrivate.phone = phone;
      personPrivate.creditCard = creditCard;
      personPrivate.aadhar_id = aadhar_id;
      personPrivate.email = email;
    }
    if (consent_type === "medium"){
      // ==== Create person object and marshal to JSON ====
      person.userID = userID;
      person.source = source;
      person.departDate = departDate;
      person.name = name;
      person.email = email;
      person.consent_type = consent_type;

      // ==== Create personPrivate object and marshal to JSON ====
      personPrivate.phone = phone;
      personPrivate.creditCard = creditCard;
      personPrivate.aadhar_id = aadhar_id;
    }
    if (consent_type === "high"){
      // ==== Create person object and marshal to JSON ====
      person.userID = userID;
      person.source = source;
      person.departDate = departDate;
      person.name = name;
      person.email = email;
      person.aadhar_id = aadhar_id;
      person.phone = phone;
      person.consent_type = consent_type;

      // ==== Create personPrivate object and marshal to JSON ====
      personPrivate.creditCard = creditCard; 
    }


    // === Save person to testCollection ===
    await stub.putPrivateData("testCollection", userID, Buffer.from(JSON.stringify(person)));  
    
    // === Save personPrivate to testCollectionPrivate ===
    await stub.putPrivateData("testCollectionPrivate", userID, Buffer.from(JSON.stringify(personPrivate)));

    console.info('- end init person');
  }

  // ===============================================
  // readPerson - read a person from testCollection
  // ===============================================
  async readPerson(stub, args, thisClass) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting user_id of the person to query');
    }

    let userID = args[0];
    if (!userID) {
      throw new Error(' user_id must not be empty');
    }
    let personAsbytes = await stub.getPrivateData("testCollection",userID); //get the person from chaincode state
    if (!personAsbytes.toString()) {
      let jsonResp = {};
      jsonResp.Error = 'Person does not exist: ' + userID;
      throw new Error(JSON.stringify(jsonResp));
    }
    console.info('=======================================');
    console.log(personAsbytes.toString());
    console.info('=======================================');
    return personAsbytes;
  }

  // ============================================================
  // readPrivatePerson - read a person from testCollectionPrivate
  // ============================================================
  async readPrivatePerson(stub, args, thisClass) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting user_id of the person to query');
    }

    let userID = args[0];
    if (!userID) {
      throw new Error(' user_id must not be empty');
    }
    let privatePersonAsbytes = await stub.getPrivateData("testCollectionPrivate",userID); //get the person from chaincode state
    if (!privatePersonAsbytes.toString()) {
      let jsonResp = {};
      jsonResp.Error = 'Person does not exist: ' + userID;
      throw new Error(JSON.stringify(jsonResp));
    }
    console.info('=======================================');
    console.log(privatePersonAsbytes.toString());
    console.info('=======================================');
    return privatePersonAsbytes;
  }

  // ===================================================
  // deletePerson - delete a person from all collections
  // ===================================================
  async deletePerson(stub, args, thisClass) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting userID of the person to delete');
    }
    let userID = args[0];
    if (!userID) {
      throw new Error('userID must not be empty');
    }

    let valAsbytes = await stub.getPrivateData("testCollection", userID); //get the person from chaincode state
    let jsonResp = {};
    if (!valAsbytes) {
      jsonResp.error = 'person does not exist';
      throw new Error(jsonResp);
    }

    //remove the person from testCollection
    await stub.deletePrivateData("testCollection", userID);

    //remove the person from testCollection
    await stub.deletePrivateData("testCollectionPrivate", userID);
  }

  // ===================================================
  // revokeConsent - delete a person from ccd collections
  // ===================================================
  async revokeConsent(stub, args, thisClass) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting userID of the person to delete');
    }
    let userID = args[0];
    if (!userID) {
      throw new Error('userID must not be empty');
    }

    let valAsbytes = await stub.getPrivateData("testCollection", userID); //get the person from chaincode state
    let jsonResp = {};
    if (!valAsbytes) {
      jsonResp.error = 'person does not exist';
      throw new Error(jsonResp);
    }

    //remove the person from testCollection
    await stub.deletePrivateData("testCollection", userID);
  }

  async updateConsent(stub, args, thisClass) {
    if (args.length < 2) {
      throw new Error('Incorrect number of arguments. Expecting userID and consent_type')
    }

    let userID = args[0];
    let new_consent_type = args[1].toLowerCase();
    console.info('- start updateConsent ', userID, new_consent_type);

    let personAsBytes = await stub.getPrivateData("testCollection", userID);
    let personPrivateAsBytes = await stub.getPrivateData("testCollectionPrivate", userID);

    if (!personAsBytes || !personAsBytes.toString()) {
      throw new Error('person does not exist');
    }

    let personJSON = {};
    try {
      personJSON = JSON.parse(personAsbytes.toString()); //unmarshal
    } catch (err) {
      let jsonResp = {};
      jsonResp.error = 'Failed to decode JSON of: ' + userID;
      throw new Error(jsonResp);
    }
    console.info(personJSON);

    let personPrivateJSON = {};
    try {
      personPrivateJSON = JSON.parse(personPrivateAsBytes.toString()); //unmarshal
    } catch (err) {
      let jsonResp = {};
      jsonResp.error = 'Failed to decode JSON of: ' + userID;
      throw new Error(jsonResp);
    }
    console.info(personPrivateJSON);

    personJSON.consent_type = new_consent_type;
    let mergedJSON = { ...personJSON, ...personPrivateJSON };

    keys = Object.keys(mergedJSON);
    for (let i = 0; i < keys.length; i++) {
      if(keys[i] !== "userID" && keys[i] !== "source" && keys[i] !== "departDate" && 
        keys[i] !== "consent_type" && keys[i] !== "name" && keys[i] !== "phone" && 
        keys[i] !== "creditCard" && keys[i] !== "aadhar_id" && keys[i] !== "email") {
        throw new Error("keys mismatch!");
      }
    }

    let person = {};
    let personPrivate = {};

    if (consent_type === "low"){
      // ==== Create person object and marshal to JSON ====
      person.userID = mergedJSON.userID;
      person.source = mergedJSON.source;
      person.departDate = mergedJSON.departDate;
      person.consent_type = mergedJSON.consent_type;
      
      // ==== Create personPrivate object and marshal to JSON ====
      personPrivate.name = mergedJSON.name;
      personPrivate.phone = mergedJSON.phone;
      personPrivate.creditCard = mergedJSON.creditCard;
      personPrivate.aadhar_id = mergedJSON.aadhar_id;
      personPrivate.email = mergedJSON.email;
    }
    if (consent_type === "medium"){
      // ==== Create person object and marshal to JSON ====
      person.userID = mergedJSON.userID;
      person.source = mergedJSON.source;
      person.departDate = mergedJSON.departDate;
      person.name = mergedJSON.name;
      person.email = mergedJSON.email;
      person.consent_type = mergedJSON.consent_type;

      // ==== Create personPrivate object and marshal to JSON ====
      personPrivate.phone = mergedJSON.phone;
      personPrivate.creditCard = mergedJSON.creditCard;
      personPrivate.aadhar_id = mergedJSON.aadhar_id;
    }
    if (consent_type === "high"){
      // ==== Create person object and marshal to JSON ====
      person.userID = mergedJSON.userID;
      person.source = mergedJSON.source;
      person.departDate = mergedJSON.departDate;
      person.name = mergedJSON.name;
      person.email = mergedJSON.email;
      person.aadhar_id = mergedJSON.aadhar_id;
      person.phone = mergedJSON.phone;
      person.consent_type = mergedJSON.consent_type;

      // ==== Create personPrivate object and marshal to JSON ====
      personPrivate.creditCard = mergedJSON.creditCard; 
    }

    // === Save person to testCollection ===
    await stub.putPrivateData("testCollection", userID, Buffer.from(JSON.stringify(person)));  
    
    // === Save personPrivate to testCollectionPrivate ===
    await stub.putPrivateData("testCollectionPrivate", userID, Buffer.from(JSON.stringify(personPrivate)));
  }
};

shim.start(new Chaincode());
