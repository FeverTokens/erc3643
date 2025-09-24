import { Provider, parseUnits } from 'ethers';

export interface GasPriceData {
  maxFeePerGas: bigint;
  maxPriorityFeePerGas: bigint;
}

const DEFAULT_MAX_FEE = () => parseUnits('25', 'gwei'); // 25 gwei
const DEFAULT_PRIORITY_FEE = () => parseUnits('1.5', 'gwei'); // 1.5 gwei

export async function fetchGasPriceData(
  provider: Provider,
  chainId: number
): Promise<GasPriceData> {
  // Initialize with default fallback values
  const gasPriceData: GasPriceData = {
    maxFeePerGas: DEFAULT_MAX_FEE(),
    maxPriorityFeePerGas: DEFAULT_PRIORITY_FEE(),
  };

  const isLocalNetwork = chainId === 31337 || chainId === 1337;

  if (isLocalNetwork) {
    try {
      const feeData = await provider.getFeeData();
      if (feeData.maxFeePerGas && feeData.maxPriorityFeePerGas) {
        return {
          maxFeePerGas: feeData.maxFeePerGas,
          maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        };
      }
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Failed to fetch local fee data:', error);
    }

    return gasPriceData;
  }

  // Try to fetch from Blocknative
  try {
    const blocknativeData = await fetchBlocknativeGasPriceData(chainId);
    gasPriceData.maxFeePerGas = blocknativeData.maxFeePerGas;
    gasPriceData.maxPriorityFeePerGas = blocknativeData.maxPriorityFeePerGas;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error(`Failed to fetch Blocknative gas data: ${error}`);
    // Continue with default values
  }

  // Try to fetch from provider if needed
  try {
    const providerData = await fetchProviderGasPriceData(provider);
    if (
      providerData.maxFeePerGas > BigInt(0) &&
      providerData.maxPriorityFeePerGas > BigInt(0)
    ) {
      gasPriceData.maxFeePerGas = providerData.maxFeePerGas;
      gasPriceData.maxPriorityFeePerGas = providerData.maxPriorityFeePerGas;
    }
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('Failed to fetch provider gas data:', error);
    // Continue with defaults
  }

  // Final sanity: ensure reasonable values
  if (!gasPriceData.maxFeePerGas || gasPriceData.maxFeePerGas <= BigInt(0)) {
    gasPriceData.maxFeePerGas = DEFAULT_MAX_FEE();
  }
  if (!gasPriceData.maxPriorityFeePerGas || gasPriceData.maxPriorityFeePerGas <= BigInt(0)) {
    gasPriceData.maxPriorityFeePerGas = DEFAULT_PRIORITY_FEE();
  }

  return gasPriceData;
}

async function fetchBlocknativeGasPriceData(
  chainId: number
): Promise<GasPriceData> {
  const url = `https://api.blocknative.com/gasprices/blockprices?chainid=${chainId}`;
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Failed to fetch gas prices: ${response.status} ${response.statusText}`);
  }

  const data: any = await response.json();
  const first = data?.blockPrices?.[0];
  if (!first || !first.estimatedPrices) {
    throw new Error('Invalid Blocknative response');
  }

  const gasEstimate = first.estimatedPrices.find((estimate: any) => estimate.confidence === 99)
    || first.estimatedPrices[0];

  if (!gasEstimate) {
    throw new Error('No suitable gas estimate found.');
  }

  return {
    maxFeePerGas: parseUnits(String(gasEstimate.maxFeePerGas), 'gwei'),
    maxPriorityFeePerGas: parseUnits(String(gasEstimate.maxPriorityFeePerGas), 'gwei'),
  };
}

export async function fetchProviderGasPriceData(
  provider: Provider
): Promise<GasPriceData> {
  try {
    // Ensure provider is ready
    await provider.getNetwork();

    const feeData = await provider.getFeeData();
    if (!feeData.maxFeePerGas || !feeData.maxPriorityFeePerGas) {
      throw new Error('Failed to retrieve fee data from provider.');
    }

    return {
      maxFeePerGas: feeData.maxFeePerGas,
      maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
    };
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error(`Failed to fetch provider fee data: ${error}`);
    // Graceful fallback
    return {
      maxFeePerGas: DEFAULT_MAX_FEE(),
      maxPriorityFeePerGas: DEFAULT_PRIORITY_FEE(),
    };
  }
}
