// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface ITokenOperationInternal {
    //Events
    event TokenPaused(bool paused);
    event TransferERC3643(
        address indexed from,
        address indexed to,
        uint256 value
    );
}
