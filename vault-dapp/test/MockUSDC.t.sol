// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockUSDC} from "../src/MockUSDC.sol";

contract MockUSDCTest is Test {
    MockUSDC usdc;
    address deployer = address(this);
    address alice = address(1);

    function setUp() public {
        usdc = new MockUSDC(1_000_000);
    }

    function testNameAndSymbol() public view {
        assertEq(usdc.name(), "USD Coin");
        assertEq(usdc.symbol(), "USDC");
    }

    function testDecimals() public view {
        assertEq(usdc.decimals(), 6);
    }

    function testInitialSupply() public view {
        assertEq(usdc.totalSupply(), 1_000_000 * 10 ** 6);
        assertEq(usdc.balanceOf(deployer), 1_000_000 * 10 ** 6);
    }

    function testOwnerCanMint() public {
        usdc.mint(alice, 500 * 10 ** 6);
        assertEq(usdc.balanceOf(alice), 500 * 10 ** 6);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        usdc.mint(alice, 500 * 10 ** 6);
    }

    function testTransfer() public {
        assertTrue(usdc.transfer(alice, 100 * 10 ** 6));
        assertEq(usdc.balanceOf(alice), 100 * 10 ** 6);
    }
}
