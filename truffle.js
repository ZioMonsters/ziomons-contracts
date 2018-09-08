module.exports = {
    networks: {
        pippo: {
            host: "localhost",
            port: 7545,
            network_id: "*", // Match any network id
            gas: 8000000,
            gasPrice: 1000
        },

        rinkeby: {
            host: "localhost", // Connect to geth on the specified
            port: 8545,
            from: "0x65f56b50b3ac0f034970e2a26d12e090fa44065b", // default address to use for any transaction Truffle makes during migrations
            network_id: 4,
            gas: 8000000 // Gas limit used for deploys
        }
}
