// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ITokenManagementInternal.sol";

interface ITokenManagement is ITokenManagementInternal{

    // Mints new tokens and assigns them to an address
    function mintERC3643(address _to, uint256 _amount) external; 

    // Burns tokens from an address
    function burnERC3643(address _userAddress, uint256 _amount) external; 
    
    // Freezes a specified amount of tokens for a user
    function freezeTokens(address user, uint256 amount) external; 

    // Unfreezes a specified amount of tokens for a user
    function unfreezeTokens(address user, uint256 amount) external;
  
    // Freezes the wallet of a user, preventing transfers
    function freezeWallet(address user) external; 
     
    // Unfreezes the wallet of a user, allowing transfers 
    function unfreezeWallet(address user) external;
   
    // Batch mints tokens to multiple addresses
    function batchMintTokens(address[] calldata _toList, uint256[] calldata _amounts) external; 
    
    // Batch burns tokens from multiple addresses
    function batchBurnTokens(address[] calldata _fromList, uint256[] calldata _amounts) external; 

}