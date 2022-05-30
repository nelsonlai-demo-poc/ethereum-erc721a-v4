//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./BaseERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFTProject is BaseERC721A {
    using ECDSA for bytes32;

    // @dev store ticket has been used
    mapping(bytes => bool) private _ticketUsed;
    bool byPassSignatureChecking = false;

    enum ProjectState {
        Prepare, //0
        WhitelistSale, //1
        PublicSale, //2
        Finished //3
    }
    ProjectState public projectState = ProjectState.Prepare;

    /**
     *  Invalid signature.
     */
    error InvalidSignature();

    /**
     *  Ticket has been used.
     */
    error TicketHasBeenUsed();

    /**
     * Not enough ETH.
     */
    error NotEnoughETH();

    /**
     *  Only EOA can call this function.
     */
    error OnlyEOACanCallThisFunction();

    /**
     *  Mint amount should great than 0.
     */
    error MintAmountShouldGreatThanZero();

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _price,
        string memory baseURI,
        address ethWallet,
        address signer
    )
        BaseERC721A(
            _name,
            _symbol,
            _maxSupply,
            _price,
            baseURI,
            ethWallet,
            signer
        )
    {
        byPassSignatureChecking = false;
    }

    /** @dev mint nft
     */
    function mint(
        uint256 _num,
        bytes memory _ticket,
        bytes calldata _signature
    ) public {
        if (
            projectState == ProjectState.WhitelistSale &&
            !byPassSignatureChecking &&
            !isSignedBySigner(msg.sender, _signer, _ticket, _signature)
        ) {
            revert InvalidSignature();
        }
        if (
            projectState == ProjectState.WhitelistSale &&
            !byPassSignatureChecking &&
            _ticketUsed[_ticket] == true
        ) {
            revert TicketHasBeenUsed();
        }
        if (msg.sender != tx.origin) {
            revert OnlyEOACanCallThisFunction();
        }
        if (_num <= 0) {
            revert MintAmountShouldGreatThanZero();
        }
        if (msg.value < (price * _num)) {
            revert NotEnoughETH();
        }
        _ticketUsed[_ticket] = true;
        payable(_ethWallet).transfer(msg.value);
        _mint(_num);
    }

    /** @dev update the project state
     */
    function setProjectState(ProjectState _state, uint256 _price)
        external
        onlyOwner
    {
        projectState = _state;
        price = _price;
    }

    /** @dev set ByPassSignatureChecking
     */
    function setByPassSignatureChecking(bool isByPass) external onlyOwner {
        byPassSignatureChecking = isByPass;
    }

    /** @dev check if the signature is signed by the signer
     */
    function isSignedBySigner(
        address _sender,
        address _signer,
        bytes memory _ticket,
        bytes calldata _signature
    ) private pure returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(_sender, _ticket));
        return _signer == hash.recover(_signature);
    }
}
