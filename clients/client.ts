// Check if window is defined and if so, access the ethereum property
const ethereum = typeof window !== 'undefined' ? window.ethereum : undefined;

// Import necessary modules
import { createPublicClient, createWalletClient, http, custom } from 'viem';
import { mainnet } from 'viem/chains';
import { EthereumProvider } from '@walletconnect/ethereum-provider';

// Declare variables outside the if block
let publicClient;
let walletClient;
let walletClientWC;

const rpcUrl = 'http://localhost:8545'; // Your RPC URL

if (ethereum) {
   console.log('Ethereum object found:', ethereum);
   // Initialization code...
} else {
   console.log('Ethereum object not found. This script is intended to run in a browser environment.');
}
// Use the ethereum variable in your code
if (ethereum) {
 // Your code that uses ethereum goes here
 publicClient = createPublicClient({
    chain: mainnet,
    transport: http(rpcUrl), // Include the RPC URL here
 });

 walletClient = createWalletClient({
    chain: mainnet,
    transport: http('https://cloudflare-eth.com'), // Use a direct RPC URL
 });

 walletClientWC = (async () => {
    const provider = await EthereumProvider.init({
      projectId: "abcd1234",
      showQrModal: true,
      chains: [1],
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