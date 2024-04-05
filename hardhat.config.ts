import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem"; 



import "@typechain/hardhat";
const config: HardhatUserConfig = {
 solidity: "0.8.24",
 networks: {
    
    // sepolia: {
    //   url: "http://localhost:8545",
    //   accounts: ["YOUR_PRIVATE_KEY"],
    // },
 },
 

 
};

export default config;
export const plugins = [
 "@nomicfoundation/hardhat-toolbox-viem",
];