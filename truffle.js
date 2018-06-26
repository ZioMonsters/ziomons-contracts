module.exports = {
    networks: {
        pippo: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*", // Match any network id
            gas: 10000000,
            gasPrice: 1000
        }
    }
};
