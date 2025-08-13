// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenInternal.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC3643 is IERC20, ITokenInternal {
    // Getters
    function onchainID() external view returns (address);
    function version() external view returns (string memory);
    function identityRegistry() external view returns (address);
    function compliance() external view returns (address);
    function paused() external view returns (bool);
    function isFrozen(address _userAddress) external view returns (bool);
    function getFrozenTokens(address _userAddress) external view returns (uint256);

    // Setters
    function setName(string calldata _name) external;
    function setSymbol(string calldata _symbol) external;
    function setOnchainID(address _onchainID) external;
    function pause() external;
    function unpause() external;
    function setAddressFrozen(address _userAddress, bool _freeze) external;
    function freezePartialTokens(address _userAddress, uint256 _amount) external;
    function unfreezePartialTokens(address _userAddress, uint256 _amount) external;
    function setIdentityRegistry(address _identityRegistry) external;
    function setCompliance(address _compliance) external;

    // Transfer actions
    function forcedTransfer(address _from, address _to, uint256 _amount) external returns (bool);
    function mint(address _to, uint256 _amount) external;
    function burn(address _userAddress, uint256 _amount) external;
    function recoveryAddress(
        address _lostWallet,
        address _newWallet,
        address _investorOnchainID
    ) external returns (bool);

    // Batch functions
    function batchTransfer(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;
    function batchForcedTransfer(
        address[] calldata _fromList,
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;
    function batchMint(
        address[] calldata _toList,
        uint256[] calldata _amounts
    ) external;
    function batchBurn(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external;
    function batchSetAddressFrozen(
        address[] calldata _userAddresses,
        bool[] calldata _freeze
    ) external;
    function batchFreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external;
    function batchUnfreezePartialTokens(
        address[] calldata _userAddresses,
        uint256[] calldata _amounts
    ) external;
}