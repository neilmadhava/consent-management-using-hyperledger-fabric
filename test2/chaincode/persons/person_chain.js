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
    if (args.length != 4) {
      throw new Error('Incorrect number of arguments. Expecting 4');
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
    let aadhar_id = args[0];
    let name = args[1];
    let email = args[2].toLowerCase();
    let phone = args[3];

    // ==== Check if person already exists ====
    let personState = await stub.getPrivateData("testCollection", aadhar_id);
    if (personState.toString()) {
      throw new Error('This person already exists: ' + aadhar_id);
    }

    // ==== Create person object and marshal to JSON ====
    let person = {};
    person.docType = 'person';
    person.aadhar_id = aadhar_id;
    person.name = name;
    person.email = email;
    person.phone = phone;

    // === Save person to state ===
    await stub.putPrivateData("testCollection",aadhar_id, Buffer.from(JSON.stringify(person)));
    // let indexName = 'color~name'
    // let colorNameIndexKey = await stub.createCompositeKey(indexName, [person.color, person.name]);
    // console.info(colorNameIndexKey);
    //  Save index entry to state. Only the key name is needed, no need to store a duplicate copy of the person.
    //  Note - passing a 'nil' value will effectively delete the key from state, therefore we pass null character as value
    // await stub.putState(colorNameIndexKey, Buffer.from('\u0000'));
    // ==== Marble saved and indexed. Return success ====
    console.info('- end init person');
  }

  // ===============================================
  // readMarble - read a person from chaincode state
  // ===============================================
  async readPerson(stub, args, thisClass) {
    if (args.length != 1) {
      throw new Error('Incorrect number of arguments. Expecting aadhar of the person to query');
    }

    let aadhar_id = args[0];
    if (!aadhar_id) {
      throw new Error(' aadhar id must not be empty');
    }
    let personAsbytes = await stub.getPrivateData("testCollection",aadhar_id); //get the person from chaincode state
    if (!personAsbytes.toString()) {
      let jsonResp = {};
      jsonResp.Error = 'Person does not exist: ' + aadhar_id;
      throw new Error(JSON.stringify(jsonResp));
    }
    console.info('=======================================');
    console.log(personAsbytes.toString());
    console.info('=======================================');
    return personAsbytes;
  }
};

shim.start(new Chaincode());
