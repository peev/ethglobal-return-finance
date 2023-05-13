// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

import {IAaveV3Pool} from "./IAaveV3Pool.sol";
import {IYearnVault} from "./IYearnVault.sol";

contract ReturnFinanceUSDCVault is ERC4626, Ownable, Pausable {
    mapping(address => bool) public whitelist;

    string public vaultName = "Return Finance USDC Vault";
    string public vaultSymbol = "rfUSDC";

    uint256 public aavePoolWeightBps = 5000;
    uint256 public yearnPoolWeightBps = 5000;

    address public usdcAddress = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address public aaveV3Pool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address public aOptUSDC = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address public usdcYVault = 0xaD17A225074191d5c8a37B50FdA1AE278a2EE6A2;

    error NotInWhitelist(address wrongAddress);
    error UnableToWithdraw(address token);
    error DepositFailed(address depositor, uint256 amount);
    error WithdrawFailed(address depositor, uint256 amount);

    modifier onlyWhitelist() {
        if (!whitelist[_msgSender()]) revert NotInWhitelist(_msgSender());
        _;
    }

    constructor() ERC4626(IERC20(usdcAddress)) ERC20(vaultName, vaultSymbol) {}
