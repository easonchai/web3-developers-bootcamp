import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Bank", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    const Bank = await ethers.getContractFactory("Bank");
    const bank = await Bank.deploy();

    return { bank };
  }

  describe("Deployment", function () {
    it("should deploy properly", async () => {
      const { bank } = await loadFixture(deployFixture);
      expect(bank.address).is.not.empty;
    });
  });

  describe("Withdrawals", function () {});
});
