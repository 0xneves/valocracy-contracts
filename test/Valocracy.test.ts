import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";
import { blocktimestamp, deploy } from "../scripts/utils";

describe("Valocracy", function () {
    let Valocracy: Contract;
    let Treasury: Contract;
    let MockERC20: Contract;
    let deployer: any;
    let Jhon: any;
    let Alice: any;

    before(async function () {
        [deployer, Jhon, Alice] = await ethers.getSigners();
        Valocracy = await deploy(deployer, "Valocracy", ["Valocracy", "gVal"]);
        console.log(Valocracy.address);
    });

    describe("SetUp Valocracy", function () {
        it("Should deploy the Treasury and Mock, then call setTreasury in the Valocracy Contract", async function () {
            // Deploy the underlying asset of the Treasury
            MockERC20 = await deploy(deployer, "MockERC20", [
                "MockERC20",
                "Mock",
            ]);

            // Deploy the Treasury itself and set the MockERC20 as the underlying asset
            Treasury = await deploy(deployer, "Treasury", [
                MockERC20.address, // Underlying Asset of the Treasury
                Valocracy.address,
                "Valocracy Treasury",
                "eVal",
            ]);

            // Mint $10k MockERC20 and transfer it to the Treasury
            await MockERC20.mint(deployer.address, 1000);
            await MockERC20.transfer(Treasury.address, 1000);

            // Set the Treasury in the Valocracy Contract
            await expect(await Valocracy.setTreasury(Treasury.address))
                .to.emit(Valocracy, "TreasuryUpdate")
                .withArgs(Treasury.address);
        });

        it("Should create a new Valor", async function () {
            const valorId = 0;
            const valorRarity = 1000;
            const valorMeta =
                "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1";

            await expect(
                await Valocracy.setValor(valorId, valorRarity, valorMeta),
            )
                .to.emit(Valocracy, "ValorUpdate")
                .withArgs(valorId, valorRarity, valorMeta);
        });

        it("Should return the rarity of the valor", async function () {
            expect(await Valocracy.rarityOf(0)).to.be.equal(1000);
        });

        it("Should return the metadata of the valor", async function () {
            expect(await Valocracy.metadataOf(0)).to.be.equal(
                "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1",
            );
        });
    });

    describe("Test Valocracy Implementation", function () {
        it("Should mint a game master token for Jhon", async function () {
            await expect(await Valocracy.mint(Jhon.address, 0))
                .to.emit(Valocracy, "Mint")
                .withArgs(Jhon.address, 0);

            const balanceOf = await Treasury.balanceOf(Jhon.address);
            console.log(balanceOf.toString(), "balanceOf Jhon");
        });

        it("Should fail to transfer the token after its been minted", async function () {
            await expect(
                Valocracy.connect(Jhon).transferFrom(
                    Jhon.address,
                    Alice.address,
                    1,
                ),
            ).to.be.revertedWithCustomError(Valocracy, "TokenSoulbound");
            expect(await Valocracy.ownerOf(1)).to.be.equal(Jhon.address);
        });

        it("Should be able to transfer the token to the zero address", async function () {
            expect(await Valocracy.ownerOf(1)).to.be.equal(Jhon.address);
            await expect(await Valocracy.connect(Jhon).burn(1))
                .to.emit(Valocracy, "Transfer")
                .withArgs(Jhon.address, ethers.constants.AddressZero, 1);
        });

        it("Should withdraw from the treasury", async function () {
            var assets = await Treasury.totalAssets();
            console.log(assets.toString(), "assets in the treasury");

            var shares = await Treasury.totalSupply();
            console.log(shares.toString(), "shares in the treasury\n");

            await expect(await Valocracy.mint(Jhon.address, 0))
                .to.emit(Valocracy, "Mint")
                .withArgs(Jhon.address, 0);

            var assets = await Treasury.totalAssets();
            console.log(assets.toString(), "assets in the treasury");

            var shares = await Treasury.totalSupply();
            console.log(shares.toString(), "shares in the treasury\n");

            await expect(await Valocracy.mint(Alice.address, 0))
                .to.emit(Valocracy, "Mint")
                .withArgs(Alice.address, 0);

            var assets = await Treasury.totalAssets();
            console.log(assets.toString(), "assets in the treasury");

            var shares = await Treasury.totalSupply();
            console.log(shares.toString(), "shares in the treasury\n");

            await expect(await Valocracy.mint(deployer.address, 0))
                .to.emit(Valocracy, "Mint")
                .withArgs(deployer.address, 0);

            var assets = await Treasury.totalAssets();
            console.log(assets.toString(), "assets in the treasury");

            var shares = await Treasury.totalSupply();
            console.log(shares.toString(), "shares in the treasury\n");

            await expect(await Valocracy.mint(deployer.address, 0))
                .to.emit(Valocracy, "Mint")
                .withArgs(deployer.address, 0);

            var assets = await Treasury.totalAssets();
            console.log(assets.toString(), "assets in the treasury");

            var shares = await Treasury.totalSupply();
            console.log(shares.toString(), "shares in the treasury\n");

            var balanceOf = await Treasury.balanceOf(deployer.address);
            console.log(balanceOf.toString(), "balanceOf deployer");
            var balanceOf = await Treasury.balanceOf(Jhon.address);
            console.log(balanceOf.toString(), "balanceOf Jhon");
            var balanceOf = await Treasury.balanceOf(Alice.address);
            console.log(balanceOf.toString(), "balanceOf Alice\n");

            console.log("MockERC20 - Before");
            var balanceOf = await MockERC20.balanceOf(deployer.address);
            console.log(balanceOf.toString(), "balanceOf deployer");
            var balanceOf = await MockERC20.balanceOf(Jhon.address);
            console.log(balanceOf.toString(), "balanceOf Jhon");
            var balanceOf = await MockERC20.balanceOf(Alice.address);
            console.log(balanceOf.toString(), "balanceOf Alice");
            var balanceOf = await Treasury.totalAssets();
            console.log(balanceOf.toString(), "balanceOf Treasury\n");

            await Treasury.connect(deployer).withdraw(deployer.address, 2000);

            console.log("MockERC20 - Post Deployer");
            var balanceOf = await MockERC20.balanceOf(deployer.address);
            console.log(balanceOf.toString(), "balanceOf deployer");
            var balanceOf = await MockERC20.balanceOf(Jhon.address);
            console.log(balanceOf.toString(), "balanceOf Jhon");
            var balanceOf = await MockERC20.balanceOf(Alice.address);
            console.log(balanceOf.toString(), "balanceOf Alice");
            var balanceOf = await Treasury.totalAssets();
            console.log(balanceOf.toString(), "balanceOf Treasury\n");

            await Treasury.connect(Alice).withdraw(Alice.address, 1000);

            console.log("MockERC20 - Post Alice");
            var balanceOf = await MockERC20.balanceOf(deployer.address);
            console.log(balanceOf.toString(), "balanceOf deployer");
            var balanceOf = await MockERC20.balanceOf(Jhon.address);
            console.log(balanceOf.toString(), "balanceOf Jhon");
            var balanceOf = await MockERC20.balanceOf(Alice.address);
            console.log(balanceOf.toString(), "balanceOf Alice");
            var balanceOf = await Treasury.totalAssets();
            console.log(balanceOf.toString(), "balanceOf Treasury\n");

            await Treasury.connect(Jhon).withdraw(Jhon.address, 1000);

            console.log("MockERC20 - Pos Jhon");
            var balanceOf = await MockERC20.balanceOf(deployer.address);
            console.log(balanceOf.toString(), "balanceOf deployer");
            var balanceOf = await MockERC20.balanceOf(Jhon.address);
            console.log(balanceOf.toString(), "balanceOf Jhon");
            var balanceOf = await MockERC20.balanceOf(Alice.address);
            console.log(balanceOf.toString(), "balanceOf Alice");
            var balanceOf = await Treasury.totalAssets();
            console.log(balanceOf.toString(), "balanceOf Treasury\n");
        });
    });
});
