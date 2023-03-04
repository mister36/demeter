// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import { console } from "forge-std/console.sol";
import { stdStorage, StdStorage, Test, DSTest } from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import { Utils } from "./utils/Utils.sol";
import "../src/vaults/GFVault.sol";
import "../src/tokens/dToken.sol";

contract GFVaultTest is Test {
    Utils internal utils;
    address user = 0x91411c9CE861b8F63e53458DA28F0A2DFE702eE3; // TODO: change
    GFVault vault;

    // usdc
    IERC20 asset = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    dToken synth;

    constructor() {}

    function setUp() public virtual {
        vm.startPrank(user);
        vault = new GFVault(asset, synth);
        utils = new Utils();
        vm.stopPrank();
    }

    // function testDeposit() public {
    //     vm.startPrank(user);

    //     // sets address usdc balance, approves
    //     deal(address(asset), user, 1000 ether);
    //     asset.approve(address(vault), 100000000 ether);

    //     uint _amount = 100 ether;
    //     vault.deposit(_amount);

    //     assertEq(asset.balanceOf(user), 900 ether);
    // }
}
