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

    function testFuzzWeekday(uint256 timestamp) public {
        timestamp = timestamp % 10**10;
        uint256 weekday = ((timestamp / 86400 + 3) % 7) + 1;
        assertEq(weekday, sut.weekday(timestamp));
    }

    function testIsLeapYear() public {
        assertTrue(sut.isLeapYear(2000));
        assertTrue(sut.isLeapYear(2024));
        assertTrue(sut.isLeapYear(2048));
        assertTrue(sut.isLeapYear(2072));
        assertTrue(sut.isLeapYear(2104));
        assertTrue(sut.isLeapYear(2128));
        assertTrue(sut.isLeapYear(10032));
        assertTrue(sut.isLeapYear(10124));
        assertTrue(sut.isLeapYear(10296));
        assertTrue(sut.isLeapYear(10400));
        assertTrue(sut.isLeapYear(10916));
    }

    function testFuzzIsLeapYear(uint256 year) public {
        assertEq(
            sut.isLeapYear(year),
            (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
        );
    }

    function testDaysInMonth() public {
        assertEq(sut.daysInMonth(2022, 1), 31);
        assertEq(sut.daysInMonth(2022, 2), 28);
        assertEq(sut.daysInMonth(2022, 3), 31);
        assertEq(sut.daysInMonth(2022, 4), 30);
        assertEq(sut.daysInMonth(2022, 5), 31);
        assertEq(sut.daysInMonth(2022, 6), 30);
        assertEq(sut.daysInMonth(2022, 7), 31);
        assertEq(sut.daysInMonth(2022, 8), 31);
        assertEq(sut.daysInMonth(2022, 9), 30);
        assertEq(sut.daysInMonth(2022, 10), 31);
        assertEq(sut.daysInMonth(2022, 11), 30);
        assertEq(sut.daysInMonth(2022, 12), 31);
        assertEq(sut.daysInMonth(2024, 1), 31);
        assertEq(sut.daysInMonth(2024, 2), 29);
        assertEq(sut.daysInMonth(1900, 2), 28);
    }

    function testDaysInMonth(uint256 year, uint256 month) public {
        month = bound(month, 1, 12);
        if (sut.isLeapYear(year) && month == 2) {
            assertEq(sut.daysInMonth(year, month), 29);
        } else if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            assertEq(sut.daysInMonth(year, month), 31);
        } else if (month == 2) {
            assertEq(sut.daysInMonth(year, month), 28);
        } else {
            assertEq(sut.daysInMonth(year, month), 30);
        }
    }
}
