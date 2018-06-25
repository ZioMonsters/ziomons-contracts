var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations, {gas: 4612388, from: "0x6C4760944552f9db4c6432E372a75D9cF5361E61"});
};
