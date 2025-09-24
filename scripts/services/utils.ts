import {
  keccak256 as _keccak256,
  toUtf8Bytes as _toUtf8Bytes,
  Signer,
  BaseContract,
  ContractFactory,
  InterfaceAbi,
  parseUnits,
} from "ethers";
import { Abi, AbiConstructor, AbiFunction, AbiEvent, AbiError } from "abitype";
import { readFileSync, existsSync } from "fs";
import { fetchGasPriceData } from "./gas";
import { join } from "path";

export interface ContractArtifact {
  file: string;
  name: string;
  abi: Abi;
  bytecode?: string;
  constructor?: AbiConstructor;
  functions?: AbiFunction[];
  events?: AbiEvent[];
  errors?: AbiError[];
}

// Load contract artifacts
const metadataPath = join(__dirname, "../../metadata/combined.json");
if (!existsSync(metadataPath)) {
  throw new Error("Combined metadata not found. Run `npm run compile` first.");
}

const artifactData = JSON.parse(readFileSync(metadataPath, "utf8"));
const AllArtifacts = artifactData.contracts;

export function keccak256(input: any): string {
  return _keccak256(input);
}

export function toUtf8Bytes(input: any): Uint8Array {
  return _toUtf8Bytes(input);
}

// Process artifacts into structured format
const artifacts: ContractArtifact[] = Object.keys(AllArtifacts).map((key) => {
  // Handle both formats: "file:name" and just "name"
  const parts = key.split(":");
  const file = parts.length > 1 ? parts[0] : "";
  const name = parts.length > 1 ? parts[1] : key;
  const artifact = AllArtifacts[key];

  return {
    file,
    name,
    abi: artifact.abi,
    bytecode: artifact.bin,
    constructor: artifact.abi.filter(
      (item: any) => item.type === "constructor",
    )[0],
    functions: artifact.abi.filter(
      (item: any) => item.type === "function" && !item.name?.endsWith("_init"),
    ),
    events: artifact.abi.filter((item: any) => item.type === "event"),
    errors: artifact.abi.filter((item: any) => item.type === "error"),
  };
});

export function getContractArtifact(
  contractArtifactName: string,
): ContractArtifact {
  const artifact = artifacts.find(
    (artifact) => artifact.name === contractArtifactName,
  );
  if (!artifact) {
    throw new Error(
      `Artifact ${contractArtifactName} not found in compilation result`,
    );
  }
  return artifact;
}

export function getAbi(contractArtifactName: string): InterfaceAbi {
  const artifact = getContractArtifact(contractArtifactName);
  return artifact.abi as InterfaceAbi;
}

export async function deployContract(
  contractArtifactName: string,
  signer: Signer,
  constructorParams?: any[],
): Promise<BaseContract> {
  const contractArtifact = getContractArtifact(contractArtifactName);
  const artifactAbi = contractArtifact.abi as InterfaceAbi;
  const artifactBytecode = contractArtifact.bytecode;

  if (!artifactBytecode) {
    throw new Error(
      `Artifact ${contractArtifactName} does not have any bytecode`,
    );
  }

  if (constructorParams && !contractArtifact.constructor) {
    throw new Error(
      `Artifact ${contractArtifactName} does not have a constructor`,
    );
  }

  const contractFactory = new ContractFactory(
    artifactAbi,
    artifactBytecode,
    signer,
  );

  // Gas overrides (EIP-1559 preferred). Precedence:
  // 1) Explicit env overrides
  // 2) Predicted gas via provider + Blocknative
  const overrides: any = {};
  const gasPriceGwei = process.env.GAS_PRICE_GWEI;
  const maxFeeGwei = process.env.MAX_FEE_GWEI;
  const maxPriorityGwei = process.env.MAX_PRIORITY_FEE_GWEI;

  if (gasPriceGwei || maxFeeGwei || maxPriorityGwei) {
    try {
      if (gasPriceGwei) overrides.gasPrice = parseUnits(gasPriceGwei, "gwei");
      if (maxFeeGwei) overrides.maxFeePerGas = parseUnits(maxFeeGwei, "gwei");
      if (maxPriorityGwei)
        overrides.maxPriorityFeePerGas = parseUnits(maxPriorityGwei, "gwei");
    } catch {}
  } else {
    try {
      const provider: any = (signer as any).provider;
      const network = await provider.getNetwork();
      const fees = await fetchGasPriceData(provider, Number(network.chainId));
      overrides.maxFeePerGas = fees.maxFeePerGas;
      overrides.maxPriorityFeePerGas = fees.maxPriorityFeePerGas;
    } catch (e) {
      // leave overrides empty to let provider fill
    }
  }

  let contract: BaseContract;
  if (constructorParams && constructorParams.length > 0) {
    contract = await (contractFactory as any).deploy(
      ...constructorParams,
      overrides,
    );
  } else {
    contract = await (contractFactory as any).deploy(overrides);
  }

  const tx = contract.deploymentTransaction();
  if (tx) {
    const confirmations = parseInt(process.env.CONFIRMATIONS || "1");
    // eslint-disable-next-line no-console
    console.log(
      `[deploy] ${contractArtifactName} tx: ${tx.hash}, waiting for ${confirmations} conf`,
    );
    await tx.wait(confirmations);
  }
  return contract;
}
