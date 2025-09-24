// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../IERC3643.sol";
import "../../token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title ERC3643 Compliant Token Interface
 * @notice Interface for ERC3643 compliant tokens with identity verification and compliance features
 * @dev This interface extends IERC20 and adds identity registry, compliance, and freezing functionality
 * @dev ERC3643 is a standard for permissioned tokens on Ethereum with built-in compliance
 */
interface IToken is IERC3643, IERC20Metadata {

}
