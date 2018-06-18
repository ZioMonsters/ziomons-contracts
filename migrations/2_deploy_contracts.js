module.exports = deployer => deployer.deploy(artifacts.require("./Core.sol", { gas: 900000000 }));
