// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ITokenManagementInternal.sol";
import "./TokenManagementStorage.sol";

abstract contract TokenManagementInternal is ITokenManagementInternal {
    function _mintERC3643(address _to, uint256 _amount) internal {
        // This could involve updating the total supply and the balance of the recipient
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        l.totalSupply += _amount;
        l.balances[_to] += _amount;
        emit TransferERC3643(address(0), _to, _amount);
    }

    function _burnERC3643(address _userAddress, uint256 _amount) internal {
        // This could involve updating the total supply and the balance of the user
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        require(l.balances[_userAddress] >= _amount, "Insufficient balance");
        l.totalSupply -= _amount;
        l.balances[_userAddress] -= _amount;
        emit TransferERC3643(_userAddress, address(0), _amount);
    }

    function _batchMintTokens(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) internal {
        require(
            _toList.length == _amounts.length,
            "Mismatched recipients and amounts"
        );
        for (uint256 i = 0; i < _toList.length; i++) {
            _mintERC3643(_toList[i], _amounts[i]);
        }
    }

    function _batchBurnTokens(
        address[] calldata _fromList,
        uint256[] calldata _amounts
    ) internal {
        require(
            _fromList.length == _amounts.length,
            "Mismatched senders and amounts"
        );
        for (uint256 i = 0; i < _fromList.length; i++) {
            _burnERC3643(_fromList[i], _amounts[i]);
        }
    }

    function _freezeTokens(address user, uint256 amount) internal {
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        // that maps an address to a uint256 representing the amount of frozen tokens.
        l.frozenTokens[user] = amount;
        emit TokensFrozen(user, amount);
    }

    function _unfreezeTokens(address user, uint256 amount) internal {
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        // that maps an address to a uint256 representing the amount of frozen tokens.
        // Directly update the frozen tokens for the user by subtracting the amount.
        l.frozenTokens[user] -= amount;
        emit TokensUnfrozen(user, amount);
    }

    function _freezeWallet(address user) internal {
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        l.walletFrozen[user] = true;
        emit WalletFrozen(user);
    }

    function _unfreezeWallet(address user) internal {
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        l.walletFrozen[user] = false;
        emit WalletUnfrozen(user);
    }
}
