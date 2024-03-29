import hre from "hardhat";
import { assert, expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";

// A deployment function to set up the initial state
const deploy = async () => {
 const erc3643Facet = await hre.viem.deployContract("ERC3643Facet", []);

 return { erc3643Facet };
};

describe("ERC3643Facet Contract Tests", function () {
 it("should add an address as an agent", async function () {
    // Load the contract instance using the deployment function
    const { erc3643Facet } = await loadFixture(deploy);

    // Define an agent address
    const agentAddress = "0x1234567890123456789012345678901234567890";

    // Add the agent
    await erc3643Facet.write.addAgent([agentAddress]);

    // Check if the address is an agent
    const isAgent = await erc3643Facet.read.isAgent([agentAddress]);

    // Assert that the address is now an agent
    assert.isTrue(isAgent);
 });

 it("should remove an address as an agent", async function () {
    // Load the contract instance using the deployment function
    const { erc3643Facet } = await loadFixture(deploy);

    // Define an agent address
    const agentAddress = "0x1234567890123456789012345678901234567890";

    // Add the agent first
    await erc3643Facet.write.addAgent([agentAddress]);

    // Remove the agent
    await erc3643Facet.write.removeAgent([agentAddress]);

    // Check if the address is no longer an agent
    const isAgent = await erc3643Facet.read.isAgent([agentAddress]);

    // Assert that the address is no longer an agent
    assert.isFalse(isAgent);
 });



 it("should verify an agent correctly", async function () {
    const { erc3643Facet } = await loadFixture(deploy);
    const agentAddress = "0x1234567890123456789012345678901234567890";

    // Assuming _verifyIdentity is implemented to return true for agents
    await erc3643Facet.write.addAgent([agentAddress]);
    const isVerified = await erc3643Facet.read.isVerified([agentAddress]);

    assert.isTrue(isVerified);
 });

 it("should check if a transfer is possible", async function () {
    const { erc3643Facet } = await loadFixture(deploy);
    const fromAddress = "0x1234567890123456789012345678901234567890";
    const toAddress = "0x9876543210987654321098765432109876543210";
    const amount = 100n;

    // Assuming _canTransfer is implemented to return true for valid transfers
    const canTransfer = await erc3643Facet.read.canTransfer([fromAddress, toAddress, amount]);

    assert.isFalse(canTransfer);
 });

 it("should mint tokens correctly", async function () {
    const { erc3643Facet } = await loadFixture(deploy);
    const toAddress = "0x9876543210987654321098765432109876543210";
    const amount = 100n;

    // Mint tokens
    await erc3643Facet.write.mintERC3643([toAddress, amount]);

    // Assuming there's a method to get the balance of an address
    const balance = await erc3643Facet.read.getBalance([toAddress]);

    assert.equal(balance, amount);
 });

 it("should burn tokens correctly", async function () {
   const { erc3643Facet } = await loadFixture(deploy);
   const userAddress = "0x1234567890123456789012345678901234567890";
   const mintAmount = 100n;
   const burnAmount = 50n;

   // Mint tokens to the user address
   await erc3643Facet.write.mintERC3643([userAddress, mintAmount]);

   // Burn tokens from the user address
   await erc3643Facet.write.burnERC3643([userAddress, burnAmount]);

   // Get the balance of the user address after burning
   const balance = await erc3643Facet.read.getBalance([userAddress]);

   // Assert that the balance is now the initial minted amount minus the burned amount
   assert.equal(balance, mintAmount - burnAmount);
});
});


