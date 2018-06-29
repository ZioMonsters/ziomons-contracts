const Web3 = require("web3");
const util = require("util");
const {readFileSync} = require("fs");
const parser_data = require("./parser_data")

const web3 = new Web3("http://localhost:7545")

const app = new web3.eth.Contract(require("./build/contracts/CryptoMon.json").abi, "0xad0fd8a5fcd7caa51cd284d4230b35094c38fe9f"); /** TODO **/

app.getPastEvents("Results", {
    fromBlock: 0,
    toBlock: "latest"
}, (err, data) => {
    data.forEach(e=>console.log(parser_data(e.returnValues._team1, e.returnValues._team2)));
    }
);
