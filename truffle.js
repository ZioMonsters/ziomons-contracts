module.exports = {
    networks: {
        pippo: {
            host: "localhost",
            port: 7545,
            network_id: "*", // Match any network id
            gas: 8000000,
            gasPrice: 1000
        }
    }
};
