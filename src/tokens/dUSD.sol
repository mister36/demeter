// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "./dToken.sol";

contract dUSD is dToken {
    constructor() dToken("Demeter USD", "dUSD") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
