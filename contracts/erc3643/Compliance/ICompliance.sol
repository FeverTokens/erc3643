// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IComplianceInternal.sol";

interface ICompliance is IComplianceInternal {
    // Initialization of the compliance contract
    function bindToken(address _token) external;
    function unbindToken(address _token) external;

    // Check the parameters of the compliance contract
    function isTokenBound(address _token) external view returns (bool);
    function getTokenBound() external view returns (address);

    // Compliance check and state update
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);
    function transferred(address _from, address _to, uint256 _amount) external;
    function created(address _to, uint256 _amount) external;
    function destroyed(address _from, uint256 _amount) external;
}