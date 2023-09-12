// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {IERC6909} from "../src/interfaces/IERC6909.sol";

contract DateTimeLibTest is Test {
    /// @dev Address of the ERC6909 contract.
    IERC6909 public sut;

    event OperatorSet(address indexed owner, address indexed spender, uint256 approved);

    /// @dev Setup the testing environment.
    function setUp() public {
        sut = IERC6909(HuffDeployer.deploy("wrappers/ERC6909Wrapper"));
    }

    function testMint() public {
        address user1 = makeAddr("user");
        assertEq(sut.balanceOf(user1, 1), 0);

        _mint(user1, 1, 1);

        assertEq(sut.balanceOf(user1, 1), 1);
    }

    function testTotalSupply() public {
        address user1 = makeAddr("user");

        _mint(user1, 1, 1);

        assertEq(sut.totalSupply(1), 1);
    }

    function testSetOperator() public {
        address user1 = makeAddr("user");

        vm.prank(address(this));
        sut.setOperator(user1, 1);

        assertEq(sut.isOperator(address(this), user1), true);
    }

    function testSetOperator_ShouldEmitEvent() public {
        address user1 = makeAddr("user");
        vm.expectEmit(true, true, true, true);
        emit OperatorSet(address(this), user1, 1);
        sut.setOperator(user1, 1);
    }

    function testSetOperator_ShouldRevert_WhenApprovedGt1() public {
        address user1 = makeAddr("user");
        vm.expectRevert();
        sut.setOperator(user1, 3);
    }

    function _mint(address user, uint256 amount, uint256 id) internal {
        address(sut).call(abi.encodeWithSignature("mint(address,uint256,uint256,bytes)", user, amount, id, ""));
    }
}
