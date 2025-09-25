// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ICompliance.sol";
import "./ComplianceInternal.sol";

contract Compliance is ICompliance, ComplianceInternal {
    
    // Initialization of the compliance contract
    function bindToken(address _token) external override {
        _bindToken(_token);
    }
    
    function unbindToken(address _token) external override {
        _unbindToken(_token);
    }

    // Check the parameters of the compliance contract
    function isTokenBound(address _token) external view override returns (bool) {
        return _isTokenBound(_token);
    }
    
    function getTokenBound() external view override returns (address) {
        return _getTokenBound();
    }

    // Compliance check and state update
    function canTransfer(address _from, address _to, uint256 _amount) external view override returns (bool) {
        return _canTransfer(_from, _to, _amount);
    }
    
    function transferred(address _from, address _to, uint256 _amount) external override {
        _transferred(_from, _to, _amount);
    }
    
    function created(address _to, uint256 _amount) external override {
        _created(_to, _amount);
    }
    
    function destroyed(address _from, uint256 _amount) external override {
        _destroyed(_from, _amount);
    }
}