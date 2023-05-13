// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";


contract ReturnFinanceUSDCVault is ERC4626, Ownable, Pausable {
    mapping(address => bool) public whitelist;

    string public vaultName = "Return Finance USDC Vault";
    string public vaultSymbol = "rfUSDC";

    uint256 public aavePoolWeightBps = 5000;
    uint256 public yearnPoolWeightBps = 5000;

    address public usdcAddress = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;


    constructor() ERC4626(IERC20(usdcAddress)) ERC20(vaultName, vaultSymbol) {}

