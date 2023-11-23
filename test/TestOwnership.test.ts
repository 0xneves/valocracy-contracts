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

	before(async function () {
		[deployer, Jhon] = await ethers.getSigners();
		Valocracy = await deploy(deployer, "Valocracy", [
		"Valocracy",
		"gVal"
		]);
		console.log(Valocracy.address);
	});

	describe("SetUp Valocracy", function () {
		it("Should deploy the Treasury and Mock, then call setTreasury in the Valocracy Contract", async function () {
			// Deploy the underlying asset of the Treasury
			MockERC20 = await deploy(deployer, "MockERC20",["MockERC20", "Mock"]);
			
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
			await expect(await Valocracy.setTreasury(Treasury.address)).to.emit(
				Valocracy,
				"TreasuryUpdate").withArgs(Treasury.address);
		})
	})
	describe("Test Ownership function", function () {

		it("Should deployer be the initial owner", async function () {
			expect(await Valocracy.owner()).to.equal(deployer.address);
		});


		it("Should only owner can setValor", async function () {
			const valorId = 0;
			const valorRarity = 1000;
			const valorMeta = "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1";
			await expect(Valocracy.connect(Jhon).setValor(0, 1000,
			"ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/1")).to.be.revertedWith(

			"Ownable: caller is not the owner"
			);

			await expect(await Valocracy.connect(deployer).setValor(valorId, valorRarity, valorMeta))
			.to.emit(Valocracy, "ValorUpdate")
			.withArgs(valorId, valorRarity, valorMeta);
		});



		it("Should only owner can mint", async function () {
		await expect(Valocracy.connect(Jhon).mint(Jhon.address, 0)).to.be.revertedWith(
			"Ownable: caller is not the owner"
			);

			await expect(await Valocracy.connect(deployer).mint(Jhon.address, 0))
			.to.emit(Valocracy, "Mint")
			.withArgs(Jhon.address, 0);
		});
	});
});