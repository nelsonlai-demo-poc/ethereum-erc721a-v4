//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./erc721a/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/** @dev BaseERC721A provides basic settings of a NFT project
 */
abstract contract BaseERC721A is ERC721AQueryable, Ownable {
    uint256 public maxSupply;
    uint256 public price;
    string private _baseURI;
    // @dev wallet to receive the eth
    address private _ethWallet;
    // @dev the address of the signer, used for signature
    address private _signer;

    constructor(
        uint256 _maxSupply,
        uint256 _price,
        string memory baseURI,
        address ethWallet,
        address signer
    ) {
        maxSupply = _maxSupply;
        price = _price;
        _baseURI = baseURI;
        _ethWallet = ethWallet;
        _signer = signer;
    }

    /** @dev set mint price of the token
     *   only owner can call this function
     */
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    /** @dev set base uri of the token
     *   only owner can call this function
     */
    function setBaseURI(string memory _uri) public onlyOwner {
        _baseURI = _uri;
    }

    /** @dev set wallet to receive the eth
     *   only owner can call this function
     */
    function setWallet(address _address) public onlyOwner {
        _ethWallet = _address;
    }

    /** @dev set signer address for signature
     *   onley owner can call this function
     */
    function setSigner(address _address) public onlyOwner {
        _signer = _address;
    }

    /** @dev mint the tokens to the sender address
     */
    function _baseMint(uint256 quantity) internal {
        _baseMint(msg.sender, quantity);
    }

    /** @dev mint the tokens to the target address
     */
    function _baseMint(address _address, uint256 quantity) internal {
        _safeMint(_address, quantity);
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
        return
            bytes(_baseURI).length > 0
                ? string.concat(_baseURI, Strings.toString(tokenId), ".json")
                : "";
    }
}
