// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @notice Interface for the DateTimeLib contract
interface IDateTimeLib {
    function weekday(uint256 timestamp) external view returns (uint256 result);

    function isLeapYear(uint256 year) external view returns (bool result);
}
