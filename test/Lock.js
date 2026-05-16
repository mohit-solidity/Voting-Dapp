const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Pool Contract", function () {

    let pool, owner, user;

    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();

        const Pool = await ethers.getContractFactory("Pool");
        pool = await Pool.deploy();
        await pool.waitForDeployment();
    });

    // 🔹 check() tests
    it("should return Perfect for correct string", async function () {
        const result = await pool.check("SPIDO");
        expect(result).to.equal("Perfect");
    });

    it("should revert for wrong string", async function () {
        await expect(pool.check("WRONG"))
            .to.be.revertedWith("Not Same");
    });

    // 🔹 pay() tests
    it("should accept ETH and update balance", async function () {
        await pool.pay({
            value: ethers.parseEther("0.02")
        });

        const balance = await pool.checkBalance();
        expect(balance).to.equal(ethers.parseEther("0.02"));
    });

    it("should revert if no ETH sent", async function () {
        await expect(pool.pay())
            .to.be.revertedWith("Must Greater Than 0 ETH");
    });

    // 🔹 checkData()
    it("should return HELLO WORLD", async function () {
        const result = await pool.checkData();
        expect(result).to.equal("HELLO WORLD");
    });
});