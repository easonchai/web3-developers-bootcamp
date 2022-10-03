import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lottery", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixture() {
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy();

    const [owner, playerA, playerB, playerC] = await ethers.getSigners();
    return { lottery, owner, playerA, playerB, playerC };
  }

  describe("Deployment", function () {
    it("should deploy properly", async () => {
      const { lottery } = await loadFixture(deployFixture);
      expect(lottery.address).is.not.empty;
    });

    it("should set the correct owner", async () => {
      const { lottery, owner, playerA } = await loadFixture(deployFixture);
      expect(await lottery.owner()).to.equal(owner.address);
      expect(await lottery.owner()).to.not.equal(playerA.address);
    });
  });

  describe("Deposit", () => {
    describe("A", () => {
      it("Should allow deposit", async () => {
        const { lottery, owner, playerA } = await loadFixture(deployFixture);
        await lottery
          .connect(playerA)
          .deposit({ value: ethers.utils.parseEther("1.0") });

        expect(await lottery.balances(playerA.address)).to.equal(
          ethers.utils.parseEther("1.0")
        );
        expect(await lottery.balances(owner.address)).to.equal(0);
      });

      it("Should allow deposit 0.1", async () => {
        const { lottery, owner, playerA } = await loadFixture(deployFixture);
        await lottery
          .connect(playerA)
          .deposit({ value: ethers.utils.parseEther("0.1") });

        expect(await lottery.balances(playerA.address)).to.equal(
          ethers.utils.parseEther("0.1")
        );
        expect(await lottery.balances(owner.address)).to.equal(0);
      });

      it("Should revert deposit", async () => {
        const { lottery, owner, playerA } = await loadFixture(deployFixture);
        await expect(lottery.deposit()).to.revertedWith(
          "Minimum buy in is 0.1 ether"
        );
      });

      it("Should revert deposit less than 0.1", async () => {
        const { lottery, owner, playerA } = await loadFixture(deployFixture);
        await expect(
          lottery
            .connect(playerA)
            .deposit({ value: ethers.utils.parseEther("0.09") })
        ).to.revertedWith("Minimum buy in is 0.1 ether");
      });
    });
  });

  describe("Withdrawals", function () {});
});
