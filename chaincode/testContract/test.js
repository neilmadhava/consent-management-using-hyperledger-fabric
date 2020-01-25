/*
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
*/

const shim = require('fabric-shim');
const util = require('util');

var Chaincode = class {

  // Initialize the chaincode
  async Init(stub) {
    console.info('=========== Instantiated test chaincode ===========');
    return shim.success();
  }

  async Invoke(stub) {
    let ret = stub.getFunctionAndParameters();
    console.info(ret);

    let method = this[ret.fcn];
    if (!method) {
      console.error('no function of name:' + ret.fcn + ' found');
      throw new Error('Received unknown function ' + ret.fcn + ' invocation');
    }
    try {
      let payload = await method(stub, ret.params);
      return shim.success(payload);
    } catch (err) {
      console.log(err);
      return shim.error(err);
    }
  }

  async initLedger(stub, args) {
    console.info('============= START : Initialize Ledger ===========');
    let persons = [];
    persons.push({
      name: 'Mukunda',
      email: 'mm@gmail.com',
      phone: '8178669876',
      aadhar_id: 'uid001'
    });
    persons.push({
      name: 'Basil',
      email: 'bgp@gmail.com',
      phone: '9872389462',
      aadhar_id: 'uid002'
    });
    persons.push({
      name: 'Manavi',
      email: 'ym@gmail.com',
      phone: '8984393824',
      aadhar_id: 'uid003'
    });
    persons.push({
      name: 'Kunj',
      email: 'kp@gmail.com',
      phone: '8765436747',
      aadhar_id: 'uid004'
    });
    persons.push({
      name: 'Madhava',
      email: 'nm@gmail.com',
      phone: '8178665876',
      aadhar_id: 'uid005'
    });

    for (let i = 0; i < persons.length; i++) {
      persons[i].docType = 'person';
      await stub.putState('PERSON' + i, Buffer.from(JSON.stringify(persons[i])));
      console.info('Added <--> ', persons[i]);
    }
    console.info('============= END : Initialize Ledger ===========');
  }

  async createPerson(stub, args) {
    console.info('============= START : Create Person ===========');
    if (args.length != 5) {
      throw new Error('Incorrect number of arguments. Expecting 5');
    }

    var person = {
      docType: 'person',
      name: args[1],
      email: args[2],
      phone: args[3],
      aadhar_id: args[4]
    };

    await stub.putState(args[0], Buffer.from(JSON.stringify(car)));
    console.info('============= END : Create Person ===========');
  }

  async queryAllPersons(stub, args) {

    let startKey = 'PERSON0';
    let endKey = 'PERSON999';

    let iterator = await stub.getStateByRange(startKey, endKey);

    let allResults = [];
    while (true) {
      let res = await iterator.next();

      if (res.value && res.value.value.toString()) {
        let jsonRes = {};
        console.log(res.value.value.toString('utf8'));

        jsonRes.Key = res.value.key;
        try {
          jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
        } catch (err) {
          console.log(err);
          jsonRes.Record = res.value.value.toString('utf8');
        }
        allResults.push(jsonRes);
      }
      if (res.done) {
        console.log('end of data');
        await iterator.close();
        console.info(allResults);
        return Buffer.from(JSON.stringify(allResults));
      }
    }
  }
};

shim.start(new Chaincode());
