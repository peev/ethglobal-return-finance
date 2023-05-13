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
    
    // To ahcieve maximum security and compliance only whitelisted wallets can deposit funds 
    // into the Return Vault Contract 
    modifier onlyWhitelist() {
        if (!whitelist[_msgSender()]) revert NotInWhitelist(_msgSender());
        _;
    }

    constructor() ERC4626(IERC20(usdcAddress)) ERC20(vaultName, vaultSymbol) {}
 
    // Deposit user USDC into the Vault (typically from Circle wallet)
    function deposit(
        uint256 amount,
        address receiver
    ) public override onlyWhitelist whenNotPaused returns (uint256 shares) {
        shares = super.deposit(amount, receiver);
        _depositToPools(amount);
        emit DepositToVault(_msgSender(), amount, block.timestamp);
    }

    // Withdraw user USDC from the Vault (typically from Circle wallet)
    function withdraw(
        uint256 amount,
        address receiver,
        address owner
    ) public override onlyWhitelist whenNotPaused returns (uint256 shares) {
        _withdrawFromPools(amount);
        shares = super.withdraw(amount, receiver, owner);
        emit WithdrawFromVault(_msgSender(), amount, block.timestamp);
    }

    // Distribute deposited USDC across AAVE and yEarn Pools equally
    function _depositToPools(uint256 amount) internal {
        uint256 amountToDepositAave = (amount * aavePoolWeightBps) / 10000;
        IERC20(usdcAddress).approve(aaveV3Pool, amountToDepositAave);
        IAaveV3Pool(aaveV3Pool).supply(
            usdcAddress,
            amountToDepositAave,
            address(this),
            0
        );
        uint256 amountToDepositYearn = (amount * yearnPoolWeightBps) / 10000;
        IERC20(usdcAddress).approve(usdcYVault, amountToDepositYearn);
        IYearnVault(usdcYVault).deposit(amountToDepositYearn);

        emit DepositToPools(amount, block.timestamp);
    }

    // Withdraw deposited USDC from AAVE and yEarn Pools upon withdraw funciton call
    function _withdrawFromPools(uint256 amount) internal {
        uint256 amountToWithdrawAave = (amount * aavePoolWeightBps) / 10000;
        IAaveV3Pool(aaveV3Pool).withdraw(
            usdcAddress,
            amountToWithdrawAave,
            address(this)
        );
        uint256 amountToWithdrawYearn = (amount * yearnPoolWeightBps) / 10000;
        uint256 pricePerShare = IYearnVault(usdcYVault).pricePerShare();
        uint256 usdcYVaultDecimals = 10 ** IYearnVault(usdcYVault).decimals();
        uint256 amountToWithdrawYearnShares = (amountToWithdrawYearn *
            usdcYVaultDecimals) / pricePerShare;
        IYearnVault(usdcYVault).withdraw(amountToWithdrawYearnShares);

        emit WithdrawFromPools(amount, block.timestamp);
    }
    // Add or remove addresses from the whitelist
    function toggleWhitelist(
        address whitelistedAddress,
        bool isWhitelisted
    ) external onlyOwner {
        whitelist[whitelistedAddress] = isWhitelisted;
        emit AddressAddedToWhitelist(whitelistedAddress, block.timestamp);
    }

    // Emergency witdraw the entire vault balance upon contract owner request
    function emergencyWithdraw(address token) external onlyOwner {
        if (token == address(0)) {
            (bool success, ) = owner().call{value: address(this).balance}("");
            if (!success) revert UnableToWithdraw(token);
            emit EmergencyWithdraw(
                token,
                address(this).balance,
                block.timestamp
            );
        } else {
            bool transferSuccess = IERC20(token).transfer(
                owner(),
                IERC20(token).balanceOf(address(this))
            );
            if (!transferSuccess) revert UnableToWithdraw(token);
            emit EmergencyWithdraw(
                token,
                IERC20(token).balanceOf(address(this)),
                block.timestamp
            );
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function totalAssets() public view override returns (uint256) {
        uint256 pricePerShare = IYearnVault(usdcYVault).pricePerShare();
        uint256 usdcYVaultDecimals = 10 ** IYearnVault(usdcYVault).decimals();

        return
            IERC20(usdcAddress).balanceOf(address(this)) +
            IERC20(aOptUSDC).balanceOf(address(this)) +
            (IERC20(usdcYVault).balanceOf(address(this)) * pricePerShare) /
            usdcYVaultDecimals;
    }

    event AddressAddedToWhitelist(address whitelistedAddress, uint256 time);
    event EmergencyWithdraw(address token, uint256 amount, uint256 time);
    event DepositToVault(address depositor, uint256 amount, uint256 time);
    event WithdrawFromVault(address depositor, uint256 amount, uint256 time);
    event DepositToPools(uint256 amount, uint256 time);
    event WithdrawFromPools(uint256 amount, uint256 time);
}
