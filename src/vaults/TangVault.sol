// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../BaseVault.sol";
import "../tokens/dToken.sol";
import "../interfaces/IBalancerPool.sol";
import "../interfaces/IAsset.sol";

contract TangVault is BaseVault {
    /// @dev Balancer's wUSDR Stable pool
    IBalancerPool pool = IBalancerPool(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    constructor(IERC20 _asset, dToken _synth) BaseVault(_asset, _synth) {
        asset.approve(address(pool), type(uint).max);
    }

    /// @inheritdoc BaseVault
    function _runStrategy(uint _amount) internal override {
        // swap usdc for wusdr
        IBalancerPool.SingleSwap memory swap;

        swap.poolId = 0x831261f44931b7da8ba0dcc547223c60bb75b47f000200000000000000000460;
        swap.kind = IBalancerPool.SwapKind.GIVEN_IN;
        swap.assetIn = IAsset(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        swap.assetOut = IAsset(0xD5a14081a34d256711B02BbEf17E567da48E80b5);
        swap.amount = _amount;
        swap.userData;

        IBalancerPool.FundManagement memory funds;
        funds.sender = address(this);
        funds.fromInternalBalance = false;
        funds.recipient = payable(address(this));
        funds.toInternalBalance = false;

        pool.swap(swap, funds, 0, ~uint256(0));
    }
}
