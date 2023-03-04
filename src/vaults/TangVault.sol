// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../BaseVault.sol";
import "../tokens/dToken.sol";
import "../interfaces/IBalancerPool.sol";
import "../interfaces/IAsset.sol";

interface IUSDRExchange {
    function swapFromUnderlying(uint256 amountIn, address to) external returns (uint256 amountOut);
}

contract TangVault is BaseVault {
    /// @dev USDR Exchange
    IUSDRExchange exchange = IUSDRExchange(0xBc02658d199bEF4F788708C807e6AEFF2232f963);

    constructor(IERC20 _asset, dToken _synth) BaseVault(_asset, _synth) {
        asset.approve(address(exchange), type(uint).max);
    }

    /// @inheritdoc BaseVault
    /// @notice will assume that deposit is DAI.
    function _runStrategy(uint _amount) internal override {
        // mint usdr
        exchange.swapFromUnderlying(_amount, address(this));
    }
}
