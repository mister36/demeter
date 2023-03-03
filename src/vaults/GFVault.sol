// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "../BaseVault.sol";
import "../interfaces/ICurveFi.sol";
import "../interfaces/IStakingRewards.sol";

// Goldfinch Vault
// Will deploy twice: one for stablecoin deposits, one for WETH
contract GFVault is BaseVault {
    /// @dev curve finance fidu-usdc pool
    ICurveFi curve = ICurveFi(0x80aa1a80a30055DAA084E599836532F3e58c95E2); // eth mainnet

    /// @dev goldfinch staking contract
    address staking = 0xFD6FF39DA508d281C2d255e9bBBfAb34B6be60c3; // eth mainnet

    constructor(IERC20 _asset, IERC20MintableBurnable _synth) BaseVault(_asset, _synth) {}

    /// @inheritdoc BaseVault
    function _runStrategy(uint _amount) internal override {
        // swap usdc for fidu
        curve.exchange_underlying(1, 0, _amount, 0);

        // stake on goldfinch
        (bool success, ) = staking.call(abi.encodeWithSignature("stake(uint256, StakedPositionType)", _amount, 0));
        require(success, "Staking failed");
    }
}
