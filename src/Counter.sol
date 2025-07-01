// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PiggyBankWithYield is ReentrancyGuard{

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error PIGGYBANK__INSUFFICIENT_BALANCE();
    error PIGGYBANK__DID_NOT_JOINED();

    uint256 private constant MINIMUM_DEPOSIT = 0.005 ether;

    constructor() {}

    mapping (address user => uint amount) public depositor;
    mapping (address => bool) public has_deposited;

    function deposit() external payable{
        require(msg.value > MINIMUM_DEPOSIT, "You must send some ether");
        depositor[msg.sender] += msg.value;
        has_deposited[msg.sender] = true;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 amount, address _to) external nonReentrant{

        if(!has_deposited[msg.sender]){
            revert PIGGYBANK__DID_NOT_JOINED();
        }

        if(depositor[msg.sender] >= amount){
            revert PIGGYBANK__INSUFFICIENT_BALANCE();
        }

        depositor[msg.sender] -= amount;

        (bool success, ) = _to.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdraw(_to, amount);

        if (depositor[msg.sender] == 0) {
            has_deposited[msg.sender] = false; // Reset if balance is zero
        }
    }

    function get_Balance() public view returns(uint256){
        return depositor[msg.sender];
    }

    function get_HasDeposited() public view returns(bool){
        return has_deposited[msg.sender];
    }

    function get_MinimumDeposit() public view returns(uint256){
        return MINIMUM_DEPOSIT;
    }

    receive() external payable {
        require(msg.value > MINIMUM_DEPOSIT, "You must send some ether");
        depositor[msg.sender] += msg.value;
        has_deposited[msg.sender] = true;
        emit Deposit(msg.sender, msg.value);
    }
}
