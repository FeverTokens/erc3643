import { Chain } from 'viem';

export const ftganacheConfig: Chain = {
 id: 1337, // Chain ID
 name: "FT Ganache", // Name of the chain
 network: "testnet", // Network type
 nativeCurrency: {
     name: "Ether", // Name of the native currency
     symbol: "ETH", // Symbol of the native currency
     decimals: 18, // Number of decimals
 },
 rpcUrls: {
     default: {
         http: ["http://a431184bd3f754da4b95e067b1e81ad4-113731396.eu-west-3.elb.amazonaws.com:8545/"],
        
     },
     public: {
         http: ["http://a431184bd3f754da4b95e067b1e81ad4-113731396.eu-west-3.elb.amazonaws.com:8545/"],
       
     },
 },
 
};