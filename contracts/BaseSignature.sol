//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/** @dev BaseSignature provides basic signature methods.
 */
abstract contract BaseSignature is Ownable {
    using ECDSA for bytes32;

    address public signerWallet;
    bool public byPassSignature = false;

    constructor(address _signer) {
        signerWallet = _signer;
    }

    /**
     *  Invalid signature.
     */
    error InvalidSignature();

    /** @dev update signer address.
     */
    function setSignerWallet(address _signer) public onlyOwner {
        signerWallet = _signer;
    }

    /** @dev update byPassSignature
     */
    function setByPassSignature(bool byPass) public onlyOwner {
        byPassSignature = byPass;
    }

    /** @dev check if the signature is signed by the signer.
     */
    function isSignedBySigner(
        address _sender,
        bytes memory _nonce,
        bytes memory _signature
    ) internal view returns (bool) {
        if (byPassSignature) {
            return true;
        }
        bytes32 hash = keccak256(abi.encodePacked(_sender, _nonce));
        return signerWallet == hash.recover(_signature);
    }
}
