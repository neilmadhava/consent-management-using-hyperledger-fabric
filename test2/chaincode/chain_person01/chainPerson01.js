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
    if (args.length != 8) {
      throw new Error('Incorrect number of arguments. Expecting 8');
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

    let userID = args[0];
    let source = args[1];
    let name = args[2];
    let departDate = args[3];
    let phone = args[4];
    let creditCard = args[5];
    let aadhar_id = args[6];
    let email = args[7];

    // ==== Check if person already exists ====
    let personState = await stub.getPrivateData("testCollection", userID);
    if (personState.toString()) {
      throw new Error('This person already exists: ' + userID);
    }

    // ==== Create person object and marshal to JSON ====
    let person = {};
    person.docType = 'person';
    person.userID = userID;
    person.source = source;
    person.name = name;
    person.departDate = departDate;

    // === Save person to state ===
    await stub.putPrivateData("testCollection",userID, Buffer.from(JSON.stringify(person)));

    // ==== Create personPrivate object and marshal to JSON ====
    let personPrivate = {};
    personPrivate.docType = 'person';
    personPrivate.phone = phone;
    personPrivate.creditCard = creditCard;
    personPrivate.aadhar_id = aadhar_id;
    personPrivate.email = email;

    await stub.putPrivateData("testCollectionPrivate",userID, Buffer.from(JSON.stringify(personPrivate)));

    console.info('- end init person');
  }

  // ===============================================
  // readMarble - read a person from chaincode state
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
};

shim.start(new Chaincode());
