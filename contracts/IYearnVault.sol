// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IYearnVault {
    function deposit(uint256 _amount) external;

    function withdraw(uint256 maxShares) external;

    function pricePerShare() external view returns (uint256);

    function decimals() external view returns (uint256);
}
