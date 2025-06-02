import hre from "hardhat";
import {assert, expect} from "chai";
import {loadFixture} from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";

// A deployment function to set up the initial state
const deploy = async () => {
	const AgentManagement = await hre.viem.deployContract("AgentManagement", []);
	const ComplianceOnChainId = await hre.viem.deployContract("ComplianceOnChainId", []);
	const TokenManagement = await hre.viem.deployContract("TokenManagement", []);
	const TokenOperation = await hre.viem.deployContract("TokenOperation", []);

	return {AgentManagement, ComplianceOnChainId, TokenManagement, TokenOperation};
};

describe("AgentManagement Contract Tests", function () {
	it("should add an address as an agent", async function () {
		// Load the contract instance using the deployment function
		const {AgentManagement} = await loadFixture(deploy);

		// Define an agent address
		const agentAddress = "0x1234567890123456789012345678901234567890";

		// Add the agent
		await AgentManagement.write.addAgent([agentAddress]);

		// Check if the address is an agent
		const isAgent = await AgentManagement.read.isAgent([agentAddress]);

		// Assert that the address is now an agent
		assert.isTrue(isAgent);
	});

	it("should remove an address as an agent", async function () {
		// Load the contract instance using the deployment function
		const {AgentManagement} = await loadFixture(deploy);

		// Define an agent address
		const agentAddress = "0x1234567890123456789012345678901234567890";

		// Add the agent first
		await AgentManagement.write.addAgent([agentAddress]);

		// Remove the agent
		await AgentManagement.write.removeAgent([agentAddress]);

		// Check if the address is no longer an agent
		const isAgent = await AgentManagement.read.isAgent([agentAddress]);

		// Assert that the address is no longer an agent
		assert.isFalse(isAgent);
	});

	it("should not verify an agent automatically", async function () {
		const {AgentManagement} = await loadFixture(deploy);
		const {ComplianceOnChainId} = await loadFixture(deploy);
		const agentAddress = "0x1234567890123456789012345678901234567890";

		// Assuming _verifyIdentity is implemented to return true for agents
		await AgentManagement.write.addAgent([agentAddress]);
		const isVerified = await ComplianceOnChainId.read.isVerified([agentAddress]);
        
		//adding agents not automatically making it a verified agent
		assert.isFalse(isVerified);
	});

	it("should check if a transfer is possible", async function () {
		const {TokenOperation} = await loadFixture(deploy);
		const fromAddress = "0x1234567890123456789012345678901234567890";
		const toAddress = "0x9876543210987654321098765432109876543210";
		const amount = 100n;

		// Assuming _canTransfer is implemented to return true for valid transfers
		const canTransfer = await TokenOperation.read.canTransfer([
			fromAddress,
			toAddress,
			amount,
		]);

		assert.isFalse(canTransfer);
	});

	it("should mint tokens correctly", async function () {
		const {TokenOperation} = await loadFixture(deploy);
		const toAddress = "0x9876543210987654321098765432109876543210";
		const amount = 100n;

		// Mint tokens
		await TokenOperation.write.mintERC3643([toAddress, amount]);

		// Assuming there's a method to get the balance of an address
		const balance = await TokenOperation.read.getBalance([toAddress]);

		assert.equal(balance, amount);
	});

	it("should burn tokens correctly", async function () {
		const {TokenOperation} = await loadFixture(deploy);
		const userAddress = "0x1234567890123456789012345678901234567890";
		const mintAmount = 100n;
		const burnAmount = 50n;

		// Mint tokens to the user address
		await TokenOperation.write.mintERC3643([userAddress, mintAmount]);

		// Burn tokens from the user address
		await TokenOperation.write.burnERC3643([userAddress, burnAmount]);

		// Get the balance of the user address after burning
		const balance = await TokenOperation.read.getBalance([userAddress]);

		// Assert that the balance is now the initial minted amount minus the burned amount
		// assert.equal(balance, mintAmount - burnAmount);
		expect(balance).to.equal(mintAmount - burnAmount);
		// await expect(deployerInstance.revokeRole(PAUSER_ROLE, publicWallet1.address)).to.be.reverted;
	});
});
