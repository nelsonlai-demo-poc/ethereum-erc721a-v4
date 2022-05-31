//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./BaseERC721A.sol";
import "./BaseSignature.sol";

/*
    BaseERC721AImpl implement the abstract BaseERC721A and BaseSignature to carry out tests.
*/

contract BaseERC721AImpl is BaseERC721A, BaseSignature {
    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        uint256 _price,
        string memory baseURI,
        address wallet,
        address _signer
    )
        BaseERC721A(name, symbol, _maxSupply, _price, baseURI, wallet)
        BaseSignature(_signer)
    {}

    /** @dev mint nft
     */
    function mint(uint256 quantity) public payable {
        _mint(quantity);
    }

    /** @dev test signature
     */
    function testSign(string memory nonce, bytes memory signature)
        public
        view
        returns (bool)
    {
        return isSignedBySigner(msg.sender, nonce, signature);
    }
}
