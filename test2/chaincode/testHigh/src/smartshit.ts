import { Chaincode, Helpers, NotFoundError, StubHelper } from '@theledger/fabric-chaincode-utils';
import * as Yup from 'yup';

export class smartshit extends Chaincode {

    async initLedger(stubHelper: StubHelper, args: string[]) {

        let persons = [{
          name: 'Mukunda',
          email: 'mm@gmail.com',
          phone: '8178669876',
          aadhar_id: 'uid001'
        }, {
          name: 'Basil',
          email: 'bgp@gmail.com',
          phone: '9872389462',
          aadhar_id: 'uid002'
        }, {
          name: 'Manavi',
          email: 'ym@gmail.com',
          phone: '8984393824',
          aadhar_id: 'uid003'
        }, {
          name: 'Kunj',
          email: 'kp@gmail.com',
          phone: '8765436747',
          aadhar_id: 'uid004'
        }, {
          name: 'Madhava',
          email: 'nm@gmail.com',
          phone: '8178665876',
          aadhar_id: 'uid005'
        }];

        for (let i = 0; i < persons.length; i++) {
            const person: any = persons[i];

            person.docType = 'person';
            await stubHelper.putState('PERSON' + i, person);
            this.logger.info('Added <--> ', person);
        }

    }

    async queryAllPersons(stubHelper: StubHelper, args: string[]): Promise<any> {

        const startKey = 'PERSON0';
        const endKey = 'PERSON999';

        return await stubHelper.getStateByRangeAsList(startKey, endKey);
    }
}