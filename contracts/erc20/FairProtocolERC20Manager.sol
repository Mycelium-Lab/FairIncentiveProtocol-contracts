// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20Universal.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FairProtocolERC20Manager is Ownable {

    address signer;
    mapping(address => mapping(ERC20Universal => uint256)) public currentCount;

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
            r,v,s,token,amount, currentCount[msg.sender][token]
        ), "FairProtocolERC20Manager: Wrong signature");
        token.transferFrom(token.owner(), msg.sender, amount);
        currentCount[msg.sender][token] += 1;
    }

    function check(
        bytes32 r,
        uint8 v,
        bytes32 s,
        ERC20Universal token,
        uint256 amount,
        uint256 count
    ) private view returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                amount,
                msg.sender,
                address(token),
                address(this),
                count
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