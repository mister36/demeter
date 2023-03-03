// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

interface IVault {
    function deposit(uint _amount) external;

    function withdraw(uint _amount) external;

    function mint(uint _amount) external;

    function repay(uint _underlyingAmount, uint _synthAmount) external;

    function liquidate(uint _amount) external;

    function harvest() external;
}
