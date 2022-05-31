const { expect } = require("chai");
const { ethers } = require("hardhat");
const { parseEther } = require("@ethersproject/units");
const { ContractFactory, Contract } = require('ethers');

describe("BaseERC721AImpl", () => {

    /** @type {ContractFactory} */
    let NFTFactory;

    /** @type {Contract} */
    let nft;

    const privateKey = "bae36fcb095314867da8ced1b8fb757109b2d5a40e713a4c7bdb95b842e7846d";
    const wallet = new ethers.Wallet(privateKey);

    /** @type {SignerWithAddress} */
    let owner;
    /** @type {SignerWithAddress} */
    let second;
    /** @type {SignerWithAddress} */
    let third;
    /** @type {SignerWithAddress} */
    let fourth;

    /** @type {SignerWithAddress} */
    let wallet1;
    /** @type {SignerWithAddress} */
    let wallet2;
    /** @type {SignerWithAddress} */
    let wallet3;
    /** @type {SignerWithAddress} */
    let wallet4;
    /** @type {SignerWithAddress} */
    let wallet5;
    /** @type {SignerWithAddress} */
    let wallet6;

    // NFT initialize settings
    const name = "TEST NFT"
    const symbol = "TEST"
    const maxSupply = 3000
    const price = parseEther("0.1")
    const baseURI = "base/uri/"
    let _wallet;
    let _signer;


    beforeEach(async () => {
        [
            owner,
            second,
            third,
            fourth,
            wallet1,
            wallet2,
            wallet3,
            wallet4,
            wallet5,
            wallet6,
        ] = await ethers.getSigners();

        _wallet = second.address;
        _signer = wallet.address;

        NFTFactory = await ethers.getContractFactory("BaseERC721AImpl");
        nft = await NFTFactory.deploy(
            name,
            symbol,
            maxSupply,
            price,
            baseURI,
            _wallet,
            _signer
        )  
    })

    describe("initialize", () => {
        it("should can setup name", async () => {
            expect(await nft.name()).to.eq(name);
        })

        it("should can setup symbol", async () => {
            expect(await nft.symbol()).to.eq(symbol);
        })

        it("should can setup maxSupply", async () => {
            expect(await nft.maxSupply()).to.eq(maxSupply);
        })

        it("should can setup price", async () => {
            expect(await nft.price()).to.eq(price);
        })

        it("should can setup eth wallet", async () => {
            expect(await nft.ethWallet()).to.eq(_wallet);
        })
    })

    describe("only owner", () => {
        it("should can be called by owner - setPrice", async () => {
            await nft.connect(owner).setPrice(price);
        })

        it("should cannot be called by non-owner - setPrice", async() => {
            await expect(nft.connect(wallet1).setPrice(price))
                .to.be.revertedWith('Ownable: caller is not the owner')
        })

        it("should can be called by owner - setBaseURI", async () => {
            await nft.connect(owner).setBaseURI(baseURI);
        })

        it("should cannot be called by owner - setBaseURI", async () => {
            await expect(nft.connect(wallet1).setBaseURI(baseURI))
                .to.be.revertedWith('Ownable: caller is not the owner')
        })

        it("should can called by owner - setWallet", async () => {
            await nft.connect(owner).setWallet(_wallet);
        })

        it("should cannot be called by owner - setWallet", async() => {
            await expect(nft.connect(wallet1).setWallet(_wallet))
                .to.be.revertedWith('Ownable: caller is not the owner')
        })

        it("should can called by owner - setSigner", async () => {
            await nft.connect(owner).setSignerWallet(_signer);
        })

        it("should cannot be called by owner - setSigner", async () => {
            await expect(nft.connect(wallet1).setSignerWallet(_signer))
                .to.be.revertedWith('Ownable: caller is not the owner')
        })

        it("should can called by owner - airdrop", async () => {
            await nft.connect(owner).airdrop([wallet1.address], 1);
        })

        it("should cannot called by owner - airdrop", async () => {
            await expect(nft.connect(wallet1).airdrop([wallet1.address], 1))
                .to.be.revertedWith('Ownable: caller is not the owner')
        })

        it("should can called by owner - airdropDynamic", async () => {
            await nft.connect(owner)
                .airdropDynamic([wallet1.address, wallet2.address], [1, 2]);
        })

        it("should cannot called by owner - airdropDynamic", async () => {
            await expect(nft.connect(wallet1)
                .airdropDynamic([wallet1.address, wallet2.address], [1, 2]))
                .to.be.revertedWith('Ownable: caller is not the owner');
        })
    })

    describe("update contract", async () => {
        it("should can update price", async () => {
            const before = await nft.price();
            await nft.connect(owner).setPrice(BigInt("200000000000000000")) // 0.2 eth
            const after = await nft.price();
            expect(before).to.not.eq(after);
            expect(after).to.eq(BigInt("200000000000000000"));
        })

        it("should can update eth wallet", async () => {
            const before = await nft.ethWallet();
            await nft.connect(owner).setWallet(third.address);
            const after = await nft.ethWallet();
            expect(before).to.not.eq(after);
            expect(after).to.eq(third.address);
        })

        it("should can update signer", async () => {
            const before = await nft.signerWallet();
            await nft.connect(owner).setSignerWallet(owner.address);
            const after = await nft.signerWallet();
            expect(before).to.not.eq(after);
            expect(after).to.eq(owner.address);
        })
    })

    describe("meta data uri", async () => {
        it("should can get the meta data uri of the token", async () => {
            await nft.connect(owner).airdrop([wallet1.address], 1)
            const url = await nft.tokenURI(0);
            expect(url).to.eq(baseURI+"0.json");
        })

        it("should can get the updated meta data uri of the token", async () => {
            await nft.connect(owner).airdrop([wallet1.address], 1)
            const updatedURI = "/updated/base/uri/"
            await nft.connect(owner).setBaseURI(updatedURI);
            const url = await nft.tokenURI(0);
            expect(url).to.eq(updatedURI+"0.json");
        })
    })

    describe("airdrop", async () => {
        it("should can airdrop to the wallets", async () => {
            await nft.connect(owner).airdrop(
                [wallet1.address, wallet2.address], 2
            );

            let balance = await nft.balanceOf(wallet1.address);
            expect(balance).to.eq(2);
            
            balance = await nft.balanceOf(wallet2.address);
            expect(balance).to.eq(2);
        })

        it("should can airdrop dynamically to the wallets", async () => {
            await nft.connect(owner).airdropDynamic(
                [wallet3.address, wallet4.address],
                [4, 8]
            );

            let balance = await nft.balanceOf(wallet3.address);
            expect(balance).to.eq(4);

            balance = await nft.balanceOf(wallet4.address);
            expect(balance).to.eq(8);
        })
    })

    describe("mint", async () => {
        it("should can mint nfts", async () => {
            await nft.connect(owner).setPrice(parseEther("0.1"));
            await nft.connect(wallet1).mint(5, { value: parseEther("0.5")})
            const balance = await nft.balanceOf(wallet1.address);
            expect(balance).to.eq(5);
        })

        it("should cannot mint nfts if not sufficient eth", async () => {
            await nft.connect(owner).setPrice(parseEther("0.1"));
            await expect(nft.connect(wallet2).mint(5, { value: parseEther("0")}))
                .to.be.revertedWith("NotEnoughETH()");
            const balance = await nft.balanceOf(wallet2.address);
            expect(balance).to.eq(0);
        })

        it("should can mint free nfts", async () => {
            await nft.connect(owner).setPrice(parseEther("0"));
            await nft.connect(wallet3).mint(5);
            const balance = await nft.balanceOf(wallet3.address);
            expect(balance).to.eq(5);
        })
    })

    describe("signature", async () => {
        
    })
})