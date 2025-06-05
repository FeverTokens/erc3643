// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenManagementInternal.sol";
import "./TokenManagementStorage.sol";
import "../AgentManagement/AgentManagementInternal.sol";
import "../../access/rbac/AccessControlInternal.sol";


abstract contract TokenManagementInternal is
    ITokenManagementInternal,
    AccessControlInternal,
    AgentManagementInternal
    
{
    modifier whenNotPaused() {
        require(!TokenManagementStorage.layout().tokenPaused, "paused");
        _;
    }

    function _freezeTokens(address user, uint256 amount) internal onlyRole(AGENT_ROLE){    
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        // that maps an address to a uint256 representing the amount of frozen tokens.
        l.frozenTokens[user] = amount;
        emit TokensFrozen(user, amount);
    }

    function _unfreezeTokens(address user, uint256 amount) internal onlyRole(AGENT_ROLE) {    
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        // that maps an address to a uint256 representing the amount of frozen tokens.
        // Directly update the frozen tokens for the user by subtracting the amount.
        l.frozenTokens[user] -= amount;
        emit TokensUnfrozen(user, amount);
    }

    function _setTokenPaused(bool _paused) internal onlyRole(AGENT_ROLE) {             
        TokenManagementStorage.Layout storage l = TokenManagementStorage
            .layout();
        l.tokenPaused = _paused;
        emit TokenPaused(_paused);
    }
}
