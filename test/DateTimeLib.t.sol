// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import {IDateTimeLib} from "../src/interfaces/IDateTimeLib.sol";

contract DateTimeLibTest is Test {
    /// @dev Address of the DateTimeLib contract.
    IDateTimeLib public sut;

    /// @dev Setup the testing environment.
    function setUp() public {
        sut = IDateTimeLib(HuffDeployer.deploy("wrappers/DateTimeLibWrapper"));
    }

    function testWeekday() public {
        assertEq(sut.weekday(1), 4);
        assertEq(sut.weekday(86400), 5);
        assertEq(sut.weekday(86401), 5);
        assertEq(sut.weekday(172800), 6);
        assertEq(sut.weekday(259200), 7);
        assertEq(sut.weekday(345600), 1);
        assertEq(sut.weekday(432000), 2);
        assertEq(sut.weekday(518400), 3);
    }

    function testWeekdayFuzz(uint256 timestamp) public {
        timestamp = timestamp % 10**10;
        uint256 weekday = ((timestamp / 86400 + 3) % 7) + 1;
        assertEq(weekday, sut.weekday(timestamp));
    }
}
