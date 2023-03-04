// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../BaseVault.sol";
import "../tokens/dToken.sol";
import "../interfaces/IPool.sol";

contract MapleVault is BaseVault {
    /// @dev M11 credit pool on Maple finance
    IPool pool = IPool(0xd3cd37a7299B963bbc69592e5Ba933388f70dc88);

    constructor(IERC20 _asset, dToken _synth) BaseVault(_asset, _synth) {
        asset.approve(address(pool), type(uint).max);
    }

    /// @inheritdoc BaseVault
    function _runStrategy(uint _amount) internal override {
        pool.deposit(_amount, address(this));
    }
}
