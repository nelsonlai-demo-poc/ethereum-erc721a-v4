//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./erc721a/ERC721A.sol";
import "./erc721a/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/** @dev BaseERC721A extends the ERC721AQueryable and provides some operations for nft project.
 */
abstract contract BaseERC721A is ERC721AQueryable, Ownable {
    uint256 public maxSupply;
    uint256 public price;
    address public ethWallet;
    string internal _uri;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        uint256 _price,
        string memory baseURI,
        address wallet
    ) ERC721A(name, symbol) {
        maxSupply = _maxSupply;
        price = _price;
        _uri = baseURI;
        ethWallet = wallet;
    }

    /**
     *  Cannot process more than 1000 tokens per transacation.
     */
    error Max1000TokenPerTransaction();

    /**
     *  Exceeds Maximum supply.
     */
    error EceedsMaximumSupply();

    /**
     *  Not enough ETH.
     */
    error NotEnoughETH();

    /** @dev set mint price of the token
     *   only owner can call this function
     */
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    /** @dev set base uri of the token
     *   only owner can call this function
     */
    function setBaseURI(string memory uri) public onlyOwner {
        _uri = uri;
    }

    /** @dev set wallet to receive the eth
     *   only owner can call this function
     */
    function setWallet(address _address) public onlyOwner {
        ethWallet = _address;
    }

    /** @dev mint the tokens to the target address
     */
    function _baseMint(address _address, uint256 quantity) internal {
        _safeMint(_address, quantity);
    }

    /** @dev mint the tokens to the sender address
     */
    function _mint(uint256 quantity) internal {
        if (quantity > 1000) {
            revert Max1000TokenPerTransaction();
        }
        if (totalSupply() + quantity > maxSupply) {
            revert EceedsMaximumSupply();
        }
        if ((price * quantity) > msg.value) {
            revert NotEnoughETH();
        }
        if (msg.value > 0) {
            payable(ethWallet).transfer(msg.value);
        }
        _baseMint(msg.sender, quantity);
    }

    /** @dev airdrop nfts to target wallet address
     */
    function airdrop(address[] calldata _address, uint256 num)
        public
        onlyOwner
    {
        if ((_address.length * num) > 1000) {
            revert Max1000TokenPerTransaction();
        }
        if (totalSupply() + (_address.length * num) > maxSupply) {
            revert EceedsMaximumSupply();
        }
        for (uint256 i = 0; i < _address.length; i++) {
            _baseMint(_address[i], num);
        }
    }

    /** @dev airdrop nfts to target wallet address with dynamic number of tokens
     */
    function airdropDynamic(
        address[] calldata _address,
        uint256[] calldata _nums
    ) public onlyOwner {
        uint256 sum = 0;
        for (uint256 i = 0; i < _nums.length; i++) {
            sum = sum + _nums[i];
        }
        if (sum > 1000) {
            revert Max1000TokenPerTransaction();
        }
        if (totalSupply() + sum > maxSupply) {
            revert EceedsMaximumSupply();
        }
        for (uint256 i = 0; i < _address.length; i++) {
            _baseMint(_address[i], _nums[i]);
        }
    }

    /** @dev return base uri of meta data
     */
    function _baseURI() internal view override returns (string memory) {
        return _uri;
    }

    /** @dev returns token uri of the token
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721A, IERC721A)
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, Strings.toString(tokenId), ".json")
                : "";
    }
}
