import shim = require('fabric-shim');
import { smartshit } from './smartshit';

// My Chaincode is moved to seperate file for testing

shim.start(new smartshit());
