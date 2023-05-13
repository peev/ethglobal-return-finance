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

    modifier onlyWhitelist() {
        if (!whitelist[_msgSender()]) revert NotInWhitelist(_msgSender());
        _;
    }

    constructor() ERC4626(IERC20(usdcAddress)) ERC20(vaultName, vaultSymbol) {}

    function deposit(
        uint256 amount,
        address receiver
    ) public override onlyWhitelist whenNotPaused returns (uint256 shares) {
        shares = super.deposit(amount, receiver);
        _depositToPools(amount);
        emit DepositToVault(_msgSender(), amount, block.timestamp);
    }

    function withdraw(
        uint256 amount,
        address receiver,
        address owner
    ) public override onlyWhitelist whenNotPaused returns (uint256 shares) {
        _withdrawFromPools(amount);
        shares = super.withdraw(amount, receiver, owner);
        emit WithdrawFromVault(_msgSender(), amount, block.timestamp);
    }

        function _depositToPools(uint256 amount) internal {
        uint256 amountToDepositAave = (amount * aavePoolWeightBps) / 10000;
        IERC20(usdcAddress).approve(aaveV3Pool, amountToDepositAave);
        IAaveV3Pool(aaveV3Pool).supply(
            usdcAddress,
            amountToDepositAave,
            address(this),
            0
        );
        emit DepositToPools(amount, block.timestamp);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    event DepositToVault(address depositor, uint256 amount, uint256 time);
    event WithdrawFromVault(address depositor, uint256 amount, uint256 time);

}
