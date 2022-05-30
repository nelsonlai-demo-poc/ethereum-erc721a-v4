const chai = require("chai");
const { ethers } = require("hardhat");

describe("NFTProject", () => {

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

    before(async () => {
        NFTFactory = await ethers.getContractFactory("NFTProject");
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
        nft = await NFTFactory.deploy(
            0, // price
            "baseUri/", // uri
            second, // eth wallet
            owner, // signer
        );
    })
})