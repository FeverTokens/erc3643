// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface ITokenManagementInternal {
    //Events
    event TransferERC3643(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event TokensFrozen(address indexed user, uint256 amount);

    event TokensUnfrozen(address indexed user, uint256 amount);

    event WalletFrozen(address indexed user);

    event WalletUnfrozen(address indexed user);
}
