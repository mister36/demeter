// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import { console } from "forge-std/console.sol";
import { stdStorage, StdStorage, Test, DSTest } from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import { Utils } from "./utils/Utils.sol";
import "../src/vaults/TangVault.sol";
import "../src/tokens/dToken.sol";
import "../src/tokens/dUSD.sol";

contract TangVaultTest is Test {
    Utils internal utils;
    address user = 0x91411c9CE861b8F63e53458DA28F0A2DFE702eE3; // TODO: change
    TangVault vault;

    // dai on polygon
    IERC20 asset = IERC20(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
    dToken synth;

    constructor() {}

    function setUp() public virtual {
        vm.startPrank(user);
        synth = new dUSD();
        vault = new TangVault(asset, synth);
        synth.grantRole(keccak256("MINTER_ROLE"), address(vault));
        synth.grantRole(keccak256("BURNER_ROLE"), address(vault));
        utils = new Utils();

        // sets address dai balance, approves
        deal(address(asset), user, 100 * (10 ** 6));
        asset.approve(address(vault), 100 * (10 ** 6));
        synth.approve(address(vault), 100 * (10 ** 6));

        vm.stopPrank();
    }

    function testDeposit() public {
        vm.startPrank(user);
        vault.deposit(50 * (10 ** 6));
        assertEq(asset.balanceOf(user), 50 * (10 ** 6));
        vm.stopPrank();
    }

    function testMint() public {
        vm.startPrank(user);

        vault.deposit(50 * (10 ** 6));
        vault.mint(10 * (10 ** 6));
        assertEq(synth.balanceOf(user), 10 * (10 ** 6));

        vm.stopPrank();
    }

    function testMintReverted() public {
        vm.startPrank(user);
        vault.deposit(50 * (10 ** 6));

        vm.expectRevert("Unhealthy collateralization ratio");
        vault.mint(26 * (10 ** 6));

        vm.stopPrank();
    }

    function testRepay() public {
        vm.startPrank(user);
        vault.deposit(50 * (10 ** 6));
        vault.mint(10 * (10 ** 6));

        vault.repay(0, 10 * (10 ** 6));
        assertEq(synth.balanceOf(user), 0);
    }
}
