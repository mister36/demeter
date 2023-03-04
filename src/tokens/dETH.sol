// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "./dToken.sol";

contract dETH is dToken {
    constructor() dToken("Demeter ETH", "dETH") {}
}
