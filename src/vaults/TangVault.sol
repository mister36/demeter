// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "../BaseVault.sol";
import "../tokens/dToken.sol";
import "../interfaces/IBalancerPool.sol";
import "../interfaces/IAsset.sol";

interface IUSDRExchange {
    function swapFromUnderlying(uint256 amountIn, address to) external returns (uint256 amountOut);

    function swapToUnderlying(uint256 amountIn, address to) external returns (uint256);
}

// Accepts Dai

contract TangVault is BaseVault, ERC4626 {
    /// @notice usdr decimals = 9, dai decimals = 18
    uint USDR_TO_DAI_SCALAR = 10 ** 9;

    /// @dev Tangible USDR Exchange
    IUSDRExchange exchange = IUSDRExchange(0xBc02658d199bEF4F788708C807e6AEFF2232f963);

    /// @dev Tangible USDR contract
    /// serves as the "special" underlying, overrides ERC4626's `_asset`
    IERC20 _asset = IERC20(0xb5DFABd7fF7F83BAB83995E72A52B97ABb7bcf63);

    constructor(
        IERC20 asset_,
        dToken _synth
    ) BaseVault(asset_, _synth) ERC4626(_asset) ERC20("TangVault Share", "TNGBL-SHR") {
        underlying.approve(address(exchange), type(uint).max);
        _asset.approve(address(exchange), type(uint).max);
    }

    /// @inheritdoc BaseVault
    /// @notice will assume that deposit is DAI.
    function _runStrategy(uint _amount, address _user) internal override {
        // mint usdr
        uint _usdrAmount = exchange.swapFromUnderlying(_amount, address(this));
        // mint shares of vault
        _mint(_user, convertToShares(_usdrAmount));
    }

    function _getEarnedYield(CDP storage _cdp, address _user) internal view override returns (uint yield) {
        uint _shares = balanceOf(_user);
        if (_shares == 0) return 0;
        uint _assets = convertToAssets(_shares);

        yield = _assets * USDR_TO_DAI_SCALAR - _cdp.totalDeposited;
    }

    function withdrawable(address _user) public view override returns (uint total) {
        total = convertToAssets(balanceOf(_user)) * USDR_TO_DAI_SCALAR;
    }

    function _sendFunds(uint _amount, address _user) internal override {
        exchange.swapToUnderlying(_amount / USDR_TO_DAI_SCALAR, _user);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
