// Check if window is defined and if so, access the ethereum property
const ethereum = typeof window !== 'undefined' ? window.ethereum : undefined;

// Import necessary modules
import { createPublicClient, createWalletClient, http, custom } from 'viem';
import { arbitrumSepolia, mainnet, sepolia } from 'viem/chains';
import { EthereumProvider } from '@walletconnect/ethereum-provider';
import dotenv from "dotenv";

dotenv.config();

// Declare variables outside the if block
let publicClient;
let walletClient;
let walletClientWC;

// Replace 'http://localhost:8545' with your actual RPC URL if different
const rpcUrl = 'https://eth.llamarpc.com	'; // Your RPC URL

if (ethereum) {
   console.log('Ethereum object found:', ethereum);

   // Initialize publicClient
   publicClient = createPublicClient({
      chain: mainnet,
      transport: http(rpcUrl), // Include the RPC URL here
   });

   // Initialize walletClient with a direct RPC URL
   walletClient = createWalletClient({
      chain: sepolia,
      transport: http(process.env.API_URL), // Use a direct RPC URL
   });

   // Initialize walletClientWC with WalletConnect
   walletClientWC = (async () => {
      // Replace 'yourProjectId' with your actual WalletConnect project ID
      const provider = await EthereumProvider.init({
         projectId: "0x1", // WalletConnect project ID
         showQrModal: true,
         chains: [1], // Chain ID for Ethereum Mainnet
      });

      return createWalletClient({
         chain: mainnet,
         transport: custom(provider),
      });
   })();
} else {
   console.log('Ethereum object not found. This script is intended to run in a browser environment.');
}

// Export the variables outside the if block
export { publicClient, walletClient, walletClientWC };