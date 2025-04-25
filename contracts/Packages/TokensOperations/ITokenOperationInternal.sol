// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITokenOperationInternal {
    //Events
    event TransferERC3643(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event WalletFrozen(address indexed user);

    event WalletUnfrozen(address indexed user);

    event WalletFrozenStatusUpdated(address indexed user, bool isFrozen);
}
