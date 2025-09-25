// Browser client helpers kept under scripts/services so they can be reused across scripts.
import { createPublicClient, createWalletClient, custom, http } from 'viem';
import { mainnet, sepolia } from 'viem/chains';
import { EthereumProvider } from '@walletconnect/ethereum-provider';
import dotenv from 'dotenv';

dotenv.config();

type PublicClientType = ReturnType<typeof createPublicClient>;
type WalletClientType = ReturnType<typeof createWalletClient>;
type WalletClientPromise = Promise<WalletClientType>;

let publicClient: PublicClientType | undefined;
let walletClient: WalletClientType | undefined;
let walletClientWC: WalletClientPromise | undefined;

const MAINNET_RPC_URL = (process.env.RPC_URL ?? 'https://eth.llamarpc.com').trim();
const SEPOLIA_RPC_URL = process.env.API_URL;
const WALLETCONNECT_PROJECT_ID = process.env.WALLETCONNECT_PROJECT_ID ?? '0x1';

const getBrowserEthereum = (): unknown => {
  if (typeof globalThis === 'undefined') {
    return undefined;
  }

  const maybeEthereum = (globalThis as Record<string, unknown>).ethereum;
  return maybeEthereum ?? undefined;
};

export const initializeBrowserClients = (): {
  publicClient: PublicClientType;
  walletClient: WalletClientType;
  walletClientWC: WalletClientPromise;
} | null => {
  if (publicClient && walletClient && walletClientWC) {
    return { publicClient, walletClient, walletClientWC };
  }

  const ethereum = getBrowserEthereum();

  if (!ethereum) {
    console.log(
      'Ethereum object not found. This script is intended to run in a browser environment.',
    );
    return null;
  }

  if (!SEPOLIA_RPC_URL) {
    console.warn('API_URL env variable is required to initialize walletClient.');
    return null;
  }

  console.log('Ethereum object found:', ethereum);

  publicClient = createPublicClient({
    chain: mainnet,
    transport: http(MAINNET_RPC_URL),
  });

  walletClient = createWalletClient({
    chain: sepolia,
    transport: http(SEPOLIA_RPC_URL),
  });

  walletClientWC = (async () => {
    const provider = await EthereumProvider.init({
      projectId: WALLETCONNECT_PROJECT_ID,
      showQrModal: true,
      chains: [mainnet.id],
    });

    return createWalletClient({
      chain: mainnet,
      transport: custom(provider),
    });
  })();

  return { publicClient, walletClient, walletClientWC };
};

export { publicClient, walletClient, walletClientWC };

export type BrowserClients = {
  publicClient: PublicClientType;
  walletClient: WalletClientType;
  walletClientWC: WalletClientPromise;
};
