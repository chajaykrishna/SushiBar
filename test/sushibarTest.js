const {expect, assert} = require("chai");

describe("deploy the contract and test functions", () => {
    before(async () => {
        const SushiToken = await ethers.getContractFactory("Sushi");
         sushiToken = await SushiToken.deploy();
        const SushiBar = await ethers.getContractFactory("SushiBar");
         sushiBar = await SushiBar.deploy(sushiToken.address);

        //set the sushibar address in the sushi token contract
        const txn = await sushiToken.setSushibarAddress(sushiBar.address);
        await txn.wait(); 

        [owner, account1] = await ethers.getSigners();
    });
    
    it("mint 1000 sushi tokens", async() => {
        await expect(sushiToken.mintSushi(owner.address, 0)).to.be.revertedWith("amount should be more than 0");
        await sushiToken.mintSushi(owner.address, 1000);
        const tokenBalance = await sushiToken.balanceOf(owner.address);
        await expect(tokenBalance).to.be.equal(1000);
    })

    it("enter the sushi bar with 500 sushi tokens", async () => {
        await expect(sushiBar.enter(0)).to.be.revertedWith("amount should be more than 0");
        await sushiBar.enter(500);
        const xSushiTokenBalance = await sushiBar.balanceOf(owner.address);
        await expect(xSushiTokenBalance).to.be.equal(500);
        const sushiTokenBalance = await sushiToken.balanceOf(owner.address);
        await expect(sushiTokenBalance).to.be.equal(500);
    });

    // try to leave the bar before 2 days, should fail
    it("leave the sushi bar before 2 days", async () => {
        await expect(sushiBar.leave(0)).to.be.revertedWith("share should be more than 0");
        await expect (sushiBar.Leave(50)).to.be.revertedWith("you can unstake sushi only after 2days");
    });
});