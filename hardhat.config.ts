import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import "hardhat-abi-exporter";
import "hardhat-gas-reporter";
import "hardhat-log-remover";
import "hardhat-output-validator";
import "hardhat-tracer";
import { HardhatUserConfig } from "hardhat/types";
import { accounts, addForkConfiguration, node_url } from "./utils/networks";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
      viaIR: true,
    },
  },
  gasReporter: {
    currency: "USD",
    gasPrice: 100,
    enabled: true,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    maxMethodDiff: 10,
  },
  networks: addForkConfiguration({
    hardhat: {
      initialBaseFeePerGas: 0, // to fix : https://github.com/sc-forks/solidity-coverage/issues/652, see https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136
    },
    localhost: {
      url: node_url("localhost"),
      accounts: accounts(),
    },
    goerli: {
      url: node_url("goerli"),
      accounts: accounts("goerli"),
    },
  }),
};

export default config;
