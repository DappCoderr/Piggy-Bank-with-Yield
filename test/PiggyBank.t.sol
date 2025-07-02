// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PiggyBank} from "../src/PiggyBank.sol";

contract CounterTest is Test {
    PiggyBank public piggyBank;

    function setUp() public {
        piggyBank = new PiggyBank();
    }

    function test_depositAndLock() public {}

    function test_Withdraw() public {}

    function test_getBalance() public {}

    function test_getHasDeposited() public {}

    function test_getMinimumDeposit() public {}
}
