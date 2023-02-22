// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";

import {IDateTimeLib} from "../src/interfaces/IDateTimeLib.sol";

contract DateTimeLibTest is Test {
    struct DateTime {
        uint256 year;
        uint256 month;
        uint256 day;
        uint256 hour;
        uint256 minute;
        uint256 second;
    }
    uint256 internal constant MON = 1;
    uint256 internal constant TUE = 2;
    uint256 internal constant WED = 3;
    uint256 internal constant THU = 4;
    uint256 internal constant FRI = 5;
    uint256 internal constant SAT = 6;
    uint256 internal constant SUN = 7;

    // Months and days of months are 1-indexed for ease of use.

    uint256 internal constant JAN = 1;
    uint256 internal constant FEB = 2;
    uint256 internal constant MAR = 3;
    uint256 internal constant APR = 4;
    uint256 internal constant MAY = 5;
    uint256 internal constant JUN = 6;
    uint256 internal constant JUL = 7;
    uint256 internal constant AUG = 8;
    uint256 internal constant SEP = 9;
    uint256 internal constant OCT = 10;
    uint256 internal constant NOV = 11;
    uint256 internal constant DEC = 12;

    // These limits are large enough for most practical purposes.
    // Inputs that exceed these limits result in undefined behavior.

    uint256 internal constant MAX_SUPPORTED_YEAR = 0xffffffff;
    uint256 internal constant MAX_SUPPORTED_EPOCH_DAY = 0x16d3e098039;
    uint256 internal constant MAX_SUPPORTED_TIMESTAMP = 0x1e18549868c76ff;
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

    function testDateToEpochDay() public {
        assertEq(sut.dateToEpochDay(1970, 1, 1), 0);
        assertEq(sut.dateToEpochDay(1970, 1, 2), 1);
        assertEq(sut.dateToEpochDay(1970, 2, 1), 31);
        assertEq(sut.dateToEpochDay(1970, 3, 1), 59);
        assertEq(sut.dateToEpochDay(1970, 4, 1), 90);
        assertEq(sut.dateToEpochDay(1970, 5, 1), 120);
        assertEq(sut.dateToEpochDay(1970, 6, 1), 151);
        assertEq(sut.dateToEpochDay(1970, 7, 1), 181);
        assertEq(sut.dateToEpochDay(1970, 8, 1), 212);
        assertEq(sut.dateToEpochDay(1970, 9, 1), 243);
        assertEq(sut.dateToEpochDay(1970, 10, 1), 273);
        assertEq(sut.dateToEpochDay(1970, 11, 1), 304);
        assertEq(sut.dateToEpochDay(1970, 12, 1), 334);
        assertEq(sut.dateToEpochDay(1970, 12, 31), 364);
        assertEq(sut.dateToEpochDay(1971, 1, 1), 365);
        assertEq(sut.dateToEpochDay(1980, 11, 3), 3959);
        assertEq(sut.dateToEpochDay(2000, 3, 1), 11017);
        assertEq(sut.dateToEpochDay(2355, 12, 31), 140982);
        assertEq(sut.dateToEpochDay(99999, 12, 31), 35804721);
        assertEq(sut.dateToEpochDay(100000, 12, 31), 35805087);

        /// These cases fail due to precision loss
        // assertEq(sut.dateToEpochDay(604800, 2, 29), 220179195);
        // assertEq(sut.dateToEpochDay(1667347200, 2, 29), 608985340227);
        // assertEq(sut.dateToEpochDay(1667952000, 2, 29), 609206238891);
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

    // prettier-ignore
    function testNthWeekdayInMonthOfYearTimestamp() public {
        uint256 wd;
        // 1st 2nd 3rd 4th monday in Novermber 2022.
        wd = MON;
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 1, wd),1667779200);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 2, wd), 1668384000);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 3, wd), 1668988800);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 4, wd), 1669593600);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 5, wd), 0);

        // 1st... 5th Wednesday in Novermber 2022.
        wd = WED;
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 1, wd), 1667347200);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 2, wd), 1667952000);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 3, wd), 1668556800);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 4, wd), 1669161600);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 5, wd), 1669766400);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 11, 6, wd), 0);

        // 1st... 5th Friday in December 2022.
        wd = FRI;
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 12, 1, wd), 1669939200);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 12, 2, wd), 1670544000);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 12, 3, wd), 1671148800);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 12, 4, wd), 1671753600);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 12, 5, wd), 1672358400);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2022, 12, 6, wd), 0);

        // 1st... 5th Sunday in January 2023.
        wd = SUN;
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2023, 1, 1, wd), 1672531200);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2023, 1, 2, wd), 1673136000);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2023, 1, 3, wd), 1673740800);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2023, 1, 4, wd), 1674345600);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2023, 1, 5, wd), 1674950400);
        assertEq(sut.nthWeekdayInMonthOfYearTimestamp(2023, 1, 6, wd), 0);
    }

    function testEpochDaysToDate() public {
        DateTime memory d;
        (d.year, d.month, d.day) = sut.epochDayToDate(0);
        assertTrue(d.year == 1970 && d.month == 1 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(31);
        assertTrue(d.year == 1970 && d.month == 2 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(59);
        assertTrue(d.year == 1970 && d.month == 3 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(90);
        assertTrue(d.year == 1970 && d.month == 4 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(120);
        assertTrue(d.year == 1970 && d.month == 5 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(151);
        assertTrue(d.year == 1970 && d.month == 6 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(181);
        assertTrue(d.year == 1970 && d.month == 7 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(212);
        assertTrue(d.year == 1970 && d.month == 8 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(243);
        assertTrue(d.year == 1970 && d.month == 9 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(273);
        assertTrue(d.year == 1970 && d.month == 10 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(304);
        assertTrue(d.year == 1970 && d.month == 11 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(334);
        assertTrue(d.year == 1970 && d.month == 12 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(365);
        assertTrue(d.year == 1971 && d.month == 1 && d.day == 1);
        (d.year, d.month, d.day) = sut.epochDayToDate(10987);
        assertTrue(d.year == 2000 && d.month == 1 && d.day == 31);
        (d.year, d.month, d.day) = sut.epochDayToDate(18321);
        assertTrue(d.year == 2020 && d.month == 2 && d.day == 29);
        (d.year, d.month, d.day) = sut.epochDayToDate(156468);
        assertTrue(d.year == 2398 && d.month == 5 && d.day == 25);
        (d.year, d.month, d.day) = sut.epochDayToDate(35805087);
        assertTrue(d.year == 100000 && d.month == 12 && d.day == 31);
    }

    function testEpochDayToDate(uint256 epochDay) public {
        DateTime memory d;
        (d.year, d.month, d.day) = sut.epochDayToDate(epochDay);
        assertEq(epochDay, sut.dateToEpochDay(d.year, d.month, d.day));
    }
}
