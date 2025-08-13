// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IComplianceInternal.sol";
import "./ComplianceStorage.sol";
import "../../access/rbac/AccessControlInternal.sol";

abstract contract ComplianceInternal is IComplianceInternal, AccessControlInternal {
    using ComplianceStorage for ComplianceStorage.Layout;
    
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");

    function _bindToken(address _token) internal onlyRole(OWNER_ROLE) {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        
        if (_token == address(0)) {
            revert InvalidTokenAddress(_token);
        }
        if (l.boundToken != address(0)) {
            revert TokenAlreadyBound(l.boundToken);
        }
        
        l.boundToken = _token;
        emit TokenBound(_token);
    }

    function _unbindToken(address _token) internal onlyRole(OWNER_ROLE) {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        
        if (l.boundToken != _token) {
            revert TokenNotBound(_token);
        }
        
        l.boundToken = address(0);
        emit TokenUnbound(_token);
    }

    function _isTokenBound(address _token) internal view returns (bool) {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        return l.boundToken == _token;
    }

    function _getTokenBound() internal view returns (address) {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        return l.boundToken;
    }

    function _canTransfer(address _from, address _to, uint256 _amount) internal view returns (bool) {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        
        // Check if transfer is restricted between these addresses
        if (l.transferRestrictions[_from][_to]) {
            return false;
        }
        
        // Check max tokens per investor
        if (l.maxTokensPerInvestor > 0) {
            uint256 toBalance = l.holderBalance[_to];
            if (toBalance + _amount > l.maxTokensPerInvestor) {
                return false;
            }
        }
        
        // Check max investors limit
        if (l.maxInvestors > 0) {
            // If _to is a new investor
            if (l.holderBalance[_to] == 0 && _amount > 0) {
                if (l.currentInvestors >= l.maxInvestors) {
                    return false;
                }
            }
        }
        
        // Additional compliance checks can be added here
        // For modular compliance, iterate through modules and check each
        
        return true;
    }

    function _transferred(address _from, address _to, uint256 _amount) internal {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        
        // Update holder balances
        if (_from != address(0)) {
            uint256 fromBalance = l.holderBalance[_from];
            l.holderBalance[_from] = fromBalance - _amount;
            
            // If sender balance becomes 0, decrease investor count
            if (l.holderBalance[_from] == 0 && fromBalance > 0) {
                l.currentInvestors--;
            }
        }
        
        if (_to != address(0)) {
            uint256 toBalance = l.holderBalance[_to];
            l.holderBalance[_to] = toBalance + _amount;
            
            // If receiver is a new investor, increase investor count
            if (toBalance == 0 && _amount > 0) {
                l.currentInvestors++;
            }
        }
        
        emit ComplianceTransferred(_from, _to, _amount);
    }

    function _created(address _to, uint256 _amount) internal {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        
        uint256 toBalance = l.holderBalance[_to];
        l.holderBalance[_to] = toBalance + _amount;
        l.totalSupply += _amount;
        
        // If receiver is a new investor, increase investor count
        if (toBalance == 0 && _amount > 0) {
            l.currentInvestors++;
        }
        
        emit ComplianceCreated(_to, _amount);
    }

    function _destroyed(address _from, uint256 _amount) internal {
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        
        uint256 fromBalance = l.holderBalance[_from];
        l.holderBalance[_from] = fromBalance - _amount;
        l.totalSupply -= _amount;
        
        // If sender balance becomes 0, decrease investor count
        if (l.holderBalance[_from] == 0 && fromBalance > 0) {
            l.currentInvestors--;
        }
        
        emit ComplianceDestroyed(_from, _amount);
    }
}