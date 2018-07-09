module.exports = {
    networks: {
        default: {
            host: "localhost",
            port: 1545,
            network_id: "*", // Match any network id
            gas: 8000000,
            gasPrice: 1000
        }
    }
};
