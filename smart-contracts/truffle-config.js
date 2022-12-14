module.exports = {
  compilers: {
    solc: {
      version: "0.4.18"
    }
  },

  networks: {
      development: {
        host: "localhost",
        port: 7545,
        gas: 4000000,
        gasPrice: '100000000000',
        network_id: "5777"
      },
      debug: {
        host: "localhost",
        port: 8545,
        network_id: "1670024396035"
      },
      hardhat: {
        host: "localhost",
        port: 8545,
        network_id: "31337"
      }
  }
}