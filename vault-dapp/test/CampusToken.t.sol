// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CampusToken.sol";

contract CampusTokenTest is Test {
    CampusToken token;
    address deployer = address(this);
    address alice = address(1);

    function setUp() public {
        token = new CampusToken(1_000_000);
    }

    function testNameAndSymbol() public view {
        assertEq(token.name(), "CampusToken");
        assertEq(token.symbol(), "CTK");
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1_000_000 * 10 ** 18);
        assertEq(token.balanceOf(deployer), 1_000_000 * 10 ** 18);
    }

    function testTransfer() public {
        token.transfer(alice, 100 * 10 ** 18);
        assertEq(token.balanceOf(alice), 100 * 10 ** 18);
    }

    function testApproveAndTransferFrom() public {
        token.approve(alice, 50 * 10 ** 18);
        assertEq(token.allowance(deployer, alice), 50 * 10 ** 18);

        vm.prank(alice);
        token.transferFrom(deployer, alice, 50 * 10 ** 18);
        assertEq(token.balanceOf(alice), 50 * 10 ** 18);
    }
}
