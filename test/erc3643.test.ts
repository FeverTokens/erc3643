import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  BrowserProvider,
  Contract,
  FunctionFragment,
  MaxUint256,
  ZeroAddress,
  parseEther,
  Signer,
} from "ethers";
import { deployContract, getAbi } from "../scripts/services/utils";

let sharedProvider: BrowserProvider | null = null;

const getBrowserProvider = async (): Promise<BrowserProvider> => {
  if (!sharedProvider) {
    sharedProvider = new BrowserProvider(hre.network.provider as any);
  }

  return sharedProvider;
};

async function getHardhatSigners(): Promise<Signer[]> {
  const provider = await getBrowserProvider();
  const accounts = await provider.listAccounts();

  return Promise.all(
    accounts.map(async (_account, index) => provider.getSigner(index)),
  );
}

async function expectRevert(promise: Promise<unknown>, reason?: string) {
  try {
    await promise;
    expect.fail(reason ?? "Expected transaction to revert");
  } catch (error: any) {
    if (!reason) {
      return;
    }

    const message = (error?.shortMessage || error?.message || "").toLowerCase();
    expect(message).to.contain(reason.toLowerCase());
  }
}

enum FacetCutAction {
  Add,
  Replace,
  Remove,
}

type DiamondCut = {
  target: string;
  action: FacetCutAction;
  selectors: string[];
};

type DiamondFixture = {
  admin: Signer;
  user1: Signer;
  user2: Signer;
  user3: Signer;
  diamondAddress: string;
  packageController: Contract;
  packageViewer: Contract;
  agentRole: Contract;
  token: Contract;
  identityRegistry: Contract;
  compliance: Contract;
};

function getFunctionSelectors(contractName: string): string[] {
  const abi = getAbi(contractName) as any[];
  return abi
    .filter(
      (item) => item.type === "function" && !item.name?.endsWith("_init"),
    )
    .map((item) => FunctionFragment.from(item).selector);
}

async function createFacetCut(
  contractName: string,
  signer: Signer,
  existingSelectors: Set<string>,
): Promise<DiamondCut | null> {
  const selectors = getFunctionSelectors(contractName).filter((selector) => {
    if (existingSelectors.has(selector)) {
      return false;
    }
    existingSelectors.add(selector);
    return true;
  });

  if (selectors.length === 0) {
    return null;
  }

  const contract = await deployContract(contractName, signer);
  return {
    target: contract.target as string,
    action: FacetCutAction.Add,
    selectors,
  };
}

export async function deployErc3643DiamondFixture(): Promise<DiamondFixture> {
  const [admin, user1, user2, user3] = await getHardhatSigners();

  const { generateMetadata } = await import("../scripts/generate-metadata");
  generateMetadata();

  const packageControllerDeployment = await deployContract(
    "PackageController",
    admin,
  );
  const packageViewerDeployment = await deployContract("PackageViewer", admin);
  const initializerDeployment = await deployContract(
    "InitializablePackage",
    admin,
  );
  const agentRoleDeployment = await deployContract("AgentRole", admin);

  const diamond = await deployContract("ERC3643PackageSystem", admin, [
    packageControllerDeployment.target,
    packageViewerDeployment.target,
    initializerDeployment.target,
    agentRoleDeployment.target,
    await admin.getAddress(),
  ]);

  const diamondAddress = diamond.target as string;

  const packageController = new Contract(
    diamondAddress,
    getAbi("PackageController"),
    admin,
  );

  const existingSelectors = new Set<string>();
  const facetCuts: DiamondCut[] = [];

  for (const name of ["IdentityRegistry", "Compliance", "Token"]) {
    const cut = await createFacetCut(name, admin, existingSelectors);
    if (cut) {
      facetCuts.push(cut);
    }
  }

  if (facetCuts.length > 0) {
    await packageController.diamondCut(facetCuts, ZeroAddress, "0x");
  }

  const packageViewer = new Contract(
    diamondAddress,
    getAbi("PackageViewer"),
    admin,
  );
  const agentRole = new Contract(diamondAddress, getAbi("AgentRole"), admin);
  const token = new Contract(diamondAddress, getAbi("Token"), admin);
  const identityRegistry = new Contract(
    diamondAddress,
    getAbi("IdentityRegistry"),
    admin,
  );
  const compliance = new Contract(
    diamondAddress,
    getAbi("Compliance"),
    admin,
  );

  await agentRole.addAgent(await admin.getAddress());

  return {
    admin,
    user1,
    user2,
    user3,
    diamondAddress,
    packageController,
    packageViewer,
    agentRole,
    token,
    identityRegistry,
    compliance,
  };
}

describe("ERC3643 Diamond", function () {
  let fixture: Awaited<ReturnType<typeof deployErc3643DiamondFixture>>;

  beforeEach(async () => {
    fixture = await loadFixture(deployErc3643DiamondFixture);
  });

  describe("Deployment", function () {
    it("deploys the diamond and core facets", async function () {
      const { diamondAddress, packageViewer, agentRole } = fixture;

      expect(diamondAddress).to.not.equal(ZeroAddress);

      const facetAddresses = await packageViewer.facetAddresses();
      expect(facetAddresses.length).to.be.greaterThan(0);
      expect(await agentRole.isAgent(await fixture.admin.getAddress())).to.be
        .true;
    });
  });

  describe("Token (ERC20)", function () {
    it("starts with zero supply", async function () {
      const { token } = fixture;
      const totalSupply = await token.totalSupply();

      expect(totalSupply).to.equal(0n);
      expect(await token.decimals()).to.be.a("bigint");
    });

    it("handles approvals and allowance tracking", async function () {
      const { token, user1, user2 } = fixture;

      const approver = await user1.getAddress();
      const spender = await user2.getAddress();
      const amount = parseEther("100");

      await token.connect(user1).approve(spender, amount);

      const allowance = await token.allowance(approver, spender);
      expect(allowance).to.equal(amount);
    });

    it("emits approval events", async function () {
      const { token, user1, user2 } = fixture;

      const approver = await user1.getAddress();
      const spender = await user2.getAddress();
      const amount = parseEther("50");

      const tx = await token.connect(user1).approve(spender, amount);
      const receipt = await tx.wait();

      const approvalEvent = token.interface.getEvent("Approval");
      const approvalTopic = approvalEvent.topicHash;
      const approvalLog = receipt?.logs?.find(
        (log: any) => log.topics?.[0] === approvalTopic,
      );

      expect(approvalLog).to.exist;

      const decoded = token.interface.decodeEventLog(
        approvalEvent,
        approvalLog?.data ?? "0x",
        approvalLog?.topics ?? [],
      ) as unknown as { owner: string; spender: string; value: bigint };

      expect(decoded.owner).to.equal(approver);
      expect(decoded.spender).to.equal(spender);
      expect(decoded.value).to.equal(amount);
    });

    it("supports maximum allowances", async function () {
      const { token, user1, user2 } = fixture;

      const approver = await user1.getAddress();
      const spender = await user2.getAddress();

      await token.connect(user1).approve(spender, MaxUint256);

      const allowance = await token.allowance(approver, spender);
      expect(allowance).to.equal(MaxUint256);
    });
  });

  describe("Identity Registry", function () {
    it("reports defaults for unregistered users", async function () {
      const { identityRegistry, user1 } = fixture;
      const address = await user1.getAddress();

      expect(await identityRegistry.contains(address)).to.be.false;
      expect(await identityRegistry.storedIdentity(address)).to.equal(
        ZeroAddress,
      );
      expect(await identityRegistry.storedInvestorCountry(address)).to.equal(0n);
    });
  });

  describe("Agent management", function () {
    it("tracks agent roles", async function () {
      const { agentRole, admin, user1 } = fixture;

      expect(await agentRole.isAgent(await admin.getAddress())).to.be.true;
      expect(await agentRole.isAgent(await user1.getAddress())).to.be.false;
    });
  });

  describe("Agent privileges", function () {
    it("allows agents to transfer without allowance", async function () {
      const { token, identityRegistry, admin, user1, user2 } = fixture;

      const user1Address = await user1.getAddress();
      const user2Address = await user2.getAddress();

      await identityRegistry
        .connect(admin)
        .registerIdentity(user1Address, user1Address, 1n);
      await identityRegistry
        .connect(admin)
        .registerIdentity(user2Address, user2Address, 1n);

      const mintAmount = parseEther("100");
      const transferAmount = parseEther("10");

      await token.connect(admin).mint(user1Address, mintAmount);
      await token
        .connect(admin)
        .transferFrom(user1Address, user2Address, transferAmount);

      expect(await token.balanceOf(user1Address)).to.equal(
        mintAmount - transferAmount,
      );
      expect(await token.balanceOf(user2Address)).to.equal(transferAmount);
    });

    it("blocks non-agents without allowance", async function () {
      const { token, identityRegistry, admin, user1, user2 } = fixture;

      const user1Address = await user1.getAddress();
      const user2Address = await user2.getAddress();

      await identityRegistry
        .connect(admin)
        .registerIdentity(user1Address, user1Address, 1n);
      await token.connect(admin).mint(user1Address, parseEther("10"));

      await expectRevert(
        token
          .connect(user2)
          .transferFrom(user1Address, user2Address, parseEther("1")),
      );
    });

    it("allows forced transfers for agents", async function () {
      const { token, identityRegistry, admin, user1, user2 } = fixture;

      const user1Address = await user1.getAddress();
      const user2Address = await user2.getAddress();

      await identityRegistry
        .connect(admin)
        .registerIdentity(user1Address, user1Address, 1n);
      await identityRegistry
        .connect(admin)
        .registerIdentity(user2Address, user2Address, 1n);

      const mintAmount = parseEther("50");
      const transferAmount = parseEther("5");

      await token.connect(admin).mint(user1Address, mintAmount);
      await token
        .connect(admin)
        .forcedTransfer(user1Address, user2Address, transferAmount);

      expect(await token.balanceOf(user1Address)).to.equal(
        mintAmount - transferAmount,
      );
      expect(await token.balanceOf(user2Address)).to.equal(transferAmount);
    });

    it("prevents forced transfers for non-agents", async function () {
      const { token, identityRegistry, admin, user1, user2 } = fixture;

      const user1Address = await user1.getAddress();
      const user2Address = await user2.getAddress();

      await identityRegistry
        .connect(admin)
        .registerIdentity(user1Address, user1Address, 1n);
      await token.connect(admin).mint(user1Address, parseEther("10"));

      await expectRevert(
        token
          .connect(user2)
          .forcedTransfer(user1Address, user2Address, parseEther("1")),
      );
    });
  });
});
