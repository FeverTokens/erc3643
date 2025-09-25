// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Disable mutability warnings for base implementation functions
// that are designed to be overridden by derived contracts
/* solhint-disable func-mutability */

import "./IComplianceInternal.sol";
import "./ComplianceStorage.sol";
import "../agent/AgentRoleInternal.sol";

abstract contract ComplianceInternal is IComplianceInternal, AgentRoleInternal {
    using ComplianceStorage for ComplianceStorage.Layout;

    function _bindToken(address _token) internal onlyOwner {
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

    function _unbindToken(address _token) internal onlyOwner {
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

    // Note: Function is view (not pure) to allow derived contracts to read state
    function _canTransfer(
        address /*_from*/,
        address /*_to*/,
        uint256 /*_value*/
    ) internal view returns (bool) {
        // Read storage to justify view mutability for inheritance pattern
        ComplianceStorage.Layout storage l = ComplianceStorage.layout();
        // Use a storage read to prevent pure mutability warning
        l.boundToken; // This access justifies view mutability
        return true;
    }

    // solhint-disable-next-line no-empty-blocks
    function _transferred(
        address _from,
        address _to,
        uint256 _amount
    ) internal {}

    // solhint-disable-next-line no-empty-blocks
    function _created(address _to, uint256 _amount) internal {}

    // solhint-disable-next-line no-empty-blocks
    function _destroyed(address _from, uint256 _amount) internal {}
}
