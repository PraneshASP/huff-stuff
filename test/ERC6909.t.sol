// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {IERC6909} from "../src/interfaces/IERC6909.sol";

contract DateTimeLibTest is Test {
    /// @dev Address of the ERC6909 contract.
    IERC6909 public sut;

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

    function _mint(address user, uint256 amount, uint256 id) internal {
        address(sut).call(abi.encodeWithSignature("mint(address,uint256,uint256,bytes)", user, amount, id, ""));
    }
}
