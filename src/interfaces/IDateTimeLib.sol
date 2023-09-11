// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @notice Interface for the DateTimeLib contract
interface IDateTimeLib {
    function weekday(uint256 timestamp) external view returns (uint256 result);

    function isLeapYear(uint256 year) external view returns (bool result);

    function daysInMonth(uint256 year, uint256 month) external view returns (uint256 result);

    function dateToEpochDay(uint256 year, uint256 month, uint256 day) external view returns (uint256 result);

    function epochDayToDate(uint256 epochDay) external view returns (uint256 year, uint256 month, uint256 day);

    function timestampToDate(uint256 timestamp) external view returns (uint256 year, uint256 month, uint256 day);

    function dateToTimestamp(uint256 year, uint256 month, uint256 day) external view returns (uint256 result);

    function dateTimeToTimestamp(uint256 year, uint256 month, uint256 day, uint256 hour, uint256 mins, uint256 secs)
        external
        view
        returns (uint256 result);

    function nthWeekdayInMonthOfYearTimestamp(uint256 wd, uint256 n, uint256 year, uint256 month)
        external
        view
        returns (uint256 result);
}
