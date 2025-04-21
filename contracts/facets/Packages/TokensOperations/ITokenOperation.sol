// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ITokenOperationInternal.sol";

interface ITokenOperation is ITokenOperationInternal{

    function transferERC3643Token(address _to, uint256 _amount) external;

    function forcedTransfer(address _from, address _to, uint256 _amount) external; 

    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external;
 
    // Recovers a specific amount of tokens from a lost wallet to a new wallet
    function recoverTokens(address lostWallet, address newWallet, uint256 amount) external; 

    // Recovers tokens from a contract to the owner
    function recoverTokensFromContract(address token, uint256 amount) external; 
    
    // Stakes a specified amount of tokens
    function stake(uint256 amount) external;

    // Unstakes a specified amount of tokens
    function unstake(uint256 amount) external;
     
    // Sells a specified amount of tokens 
    function sellTokens(uint256 amount) external; 

    // Swaps tokens with another contract
    function swapTokens(address token, uint256 amount) external;
}