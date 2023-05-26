// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20Universal.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FairProtocolERC20Manager is Ownable {

    address signer;

    constructor(address _signer) {
        signer = _signer;
    }

    function mintSigner(
        bytes32 r,
        uint8 v,
        bytes32 s,
        ERC20Universal token,
        uint256 amount
    ) external {
        require(check(
            r,v,s,token,amount
        ), "FairProtocolERC20Manager: Wrong signature");
        token.transferFrom(token.owner(), msg.sender, amount);
    }

    function check(
        bytes32 r,
        uint8 v,
        bytes32 s,
        ERC20Universal token,
        uint256 amount
    ) private view returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                amount,
                msg.sender,
                address(token),
                address(this)
            )
        );
        return
            signer ==
            ecrecover(
                keccak256(
                    abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
                ),
                v,
                r,
                s
            );
    }

}