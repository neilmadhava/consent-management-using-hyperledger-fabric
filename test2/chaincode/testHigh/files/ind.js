"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var shim = require("fabric-shim");
var smartshit_1 = require("./smartshit");
// My Chaincode is moved to seperate file for testing
shim.start(new smartshit_1.smartshit());
