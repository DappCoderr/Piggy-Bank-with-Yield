// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PiggyBankWithYield is ReentrancyGuard {
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error PIGGYBANK__INSUFFICIENT_BALANCE();
    error PIGGYBANK__DID_NOT_JOINED();
    error PIGGYBANK__MUST_BE_GREATER_THAN_MIN_DEPOSIT();
    error PIGGYBANK__TRANSFER_FAIL();

    uint256 private constant MINIMUM_DEPOSIT = 0.005 ether;

    constructor() {}

    mapping(address user => uint256 amount) public depositor;
    mapping(address => bool) public hasDeposited;

    function deposit() external payable {
        if(msg.value > MINIMUM_DEPOSIT) {
            revert PIGGYBANK__MUST_BE_GREATER_THAN_MIN_DEPOSIT();
        }
        if(!hasDeposited[msg.sender]){
            hasDeposited[msg.sender] = true;
        }
        depositor[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount, address _to) external nonReentrant {
        if (!hasDeposited[msg.sender]) {
            revert PIGGYBANK__DID_NOT_JOINED();
        }

        if (depositor[msg.sender] >= amount) {
            revert PIGGYBANK__INSUFFICIENT_BALANCE();
        }

        depositor[msg.sender] -= amount;

        (bool success,) = _to.call{value: amount}("");
        if(!success){
            revert PIGGYBANK__TRANSFER_FAIL();
        }

        emit Withdraw(_to, amount);

        if (depositor[msg.sender] == 0) {
            hasDeposited[msg.sender] = false; // Reset if balance is zero
        }
    }

    function getBalance() public view returns (uint256) {
        return depositor[msg.sender];
    }

    function getHasDeposited() public view returns (bool) {
        return hasDeposited[msg.sender];
    }

    function getMinimumDeposit() public pure returns (uint256) {
        return MINIMUM_DEPOSIT;
    }

    receive() external payable {
        if(msg.value > MINIMUM_DEPOSIT) {
            revert PIGGYBANK__MUST_BE_GREATER_THAN_MIN_DEPOSIT();
        }
        depositor[msg.sender] += msg.value;
        hasDeposited[msg.sender] = true;
        emit Deposit(msg.sender, msg.value);
    }
}
