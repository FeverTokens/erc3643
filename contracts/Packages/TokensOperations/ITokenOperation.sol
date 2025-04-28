// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenOperationInternal.sol";

interface ITokenOperation is ITokenOperationInternal {
    function init__ERC20Metadata(
        string memory __name,
        string memory __symbol,
        uint8 __decimals
    ) external;

    function transferERC3643Token(
        address _to,
        uint256 _amount
    ) external returns (bool status);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function totalStaked() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stakedBalance(address account) external view returns (uint256);

    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external;

    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external returns (bool);

    // Mints new tokens and assigns them to an address
    function mintERC3643(address _to, uint256 _amount) external;

    // Burns tokens from an address
    function burnERC3643(address _userAddress, uint256 _amount) external;

    // Batch mints tokens to multiple addresses
    function batchMintTokens(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;

    // Batch burns tokens from multiple addresses
    function batchBurnTokens(
        address[] calldata _fromList,
        uint256[] calldata _amounts
    ) external;

    // Recovers a specific amount of tokens from a lost wallet to a new wallet
    function recoverTokens(
        address lostWallet,
        address newWallet,
        uint256 amount
    ) external;

    // Recovers tokens from a contract to the owner
    function recoverTokensFromContract(address token, uint256 amount) external;

    // Stakes a specified amount of tokens
    function stake(uint256 amount) external returns (uint256);

    // Unstakes a specified amount of tokens
    function unstake(uint256 amount) external returns (uint256);

    // Sells a specified amount of tokens
    function sellTokens(uint256 amount) external;

    // Swaps tokens with another contract
    function swapTokens(address token, uint256 amount) external;

    // Freezes the wallet of a user, preventing transfers
    function freezeWallet(address user) external;

    // Unfreezes the wallet of a user, allowing transfers
    function unfreezeWallet(address user) external;

    // Batch updates the frozen status of multiple addresses
    function batchUpdateFrozenStatus(
        address[] calldata _addresses,
        bool[] calldata _statuses
    ) external;
}
