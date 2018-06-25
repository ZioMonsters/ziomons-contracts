const Web3 = require('web3');
const {readFileSync} = require('fs');
const solc = require('solc');


if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider)
} else {
  // set the provider you want from Web3.providers
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))
}

const sources = {
    'Core.sol': readFileSync('./contracts/Core.sol'),
    'ERCCore.sol': readFileSync('./contracts/ERCCore.sol'),
    'Owned.sol': readFileSync('./contracts/Owned.sol'),
    'State.sol': readFileSync('./contracts/State.sol'),
    'CryptoMon.sol': readFileSync('./contracts/CryptoMon.sol'),
    'Interfaces.sol': readFileSync('./contracts/Interfaces.sol'),
    'Mortal.sol': readFileSync('./contracts/Mortal.sol'),
    'SafeMath.sol': readFileSync('./contracts/SafeMath.sol'),
    'CoreFunctions.sol': readFileSync('./contracts/CoreFunctions.sol'),
    'AdminPanel.sol': readFileSync('./contracts/AdminPanel.sol')
}

const compiled = solc.compile({sources}, 1);
const abi = compiled.contracts['CryptoMon.sol:CryptoMon'].interface;
const bytecode = compiled.contracts['CryptoMon.sol:CryptoMon'].bytecode;

writeFileSync('./build/contracts/CryptoMon.json', JSON.stringify(abi));

const contract = web3.eth.contract(JSON.parse(abi));

const instance = contract.new({
  data: '0x' + bytecode,
  from: web3.eth.accounts[0],
  gas: 4712388
}, (err, res) => {
  if(!address) address = res.address;
});
