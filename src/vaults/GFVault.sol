// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../BaseVault.sol";
import "../interfaces/ICurveFi.sol";
import "../tokens/dToken.sol";

// Goldfinch Vault
// Will deploy twice: one for stablecoin deposits, one for WETH
contract GFVault is BaseVault {
    /// @dev curve finance fidu-usdc pool
    ICurveFi curve = ICurveFi(0x80aa1a80a30055DAA084E599836532F3e58c95E2); // eth mainnet

    /// @dev goldfinch staking contract
    address staking = 0xFD6FF39DA508d281C2d255e9bBBfAb34B6be60c3; // eth mainnet

    /// @dev fidu contract
    IERC20 fidu = IERC20(0x6a445E9F40e0b97c92d0b8a3366cEF1d67F700BF);

    constructor(IERC20 _asset, dToken _synth) BaseVault(_asset, _synth) {
        asset.approve(address(curve), type(uint).max);
    }

    /// @inheritdoc BaseVault
    function _runStrategy(uint _amount) internal override {
        // swap usdc for fidu
        curve.exchange_underlying(1, 0, _amount, 0);

        uint _balance = fidu.balanceOf(address(this));

        require(_balance > 0, "too low");

        // stake on goldfinch
        (bool success, bytes memory data) = staking.call(
            abi.encodeWithSignature("stake(uint256, StakedPositionType)", _balance, 0)
        );
        require(success, "Staking failed");
    }
}
