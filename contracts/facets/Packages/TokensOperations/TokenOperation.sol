// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ITokenOperation.sol";
import "./TokenOperationInternal.sol";

contract TokenOperation is ITokenOperation, TokenOperationInternal {
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool) {
        return _canTransfer(_from, _to, _amount);
    }

    function transferERC3643Token(
        address _to,
        uint256 _amount
    ) external override {
        _transferERC3643(msg.sender, _to, _amount);
    }

    function getBalance(address _userAddress) external view returns (uint256) {
        return _getBalance(_userAddress);
    }

    function forcedTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external override {
        _forcedTransfer(_from, _to, _amount);
    }

    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external override {
        _batchTransfer(recipients, amounts);
    }

    // recovery-related functions such as recovering tokens and tokens from contracts.
    function recoverTokens(
        address lostWallet,
        address newWallet,
        uint256 amount
    ) external override {
        _recoverTokens(lostWallet, newWallet, amount);
    }

    function recoverTokensFromContract(
        address token,
        uint256 amount
    ) external override {
        _recoverTokensFromContract(token, amount);
    }

    // staking-related functions such as staking and unstaking tokens.
    function stake(uint256 amount) external override {
        _stake(amount);
    }

    function unstake(uint256 amount) external override {
        _unstake(amount);
    }

    // swap-related functions such as selling and swapping tokens.
    function sellTokens(uint256 amount) external override {
        _sellTokens(amount);
    }

    function swapTokens(address token, uint256 amount) external override {
        _swapTokens(token, amount);
    }
}
