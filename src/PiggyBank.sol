// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract PiggyBank is ReentrancyGuard {
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event TokenLocked(address indexed user, uint256 amount);

    error PIGGYBANK__INSUFFICIENT_BALANCE();
    error PIGGYBANK__DID_NOT_JOINED();
    error PIGGYBANK__MUST_BE_GREATER_THAN_MIN_DEPOSIT();
    error PIGGYBANK__TRANSFER_FAIL();

    struct Lock {
        uint256 amount;
        uint32 updatedAt;
        uint32 expiresAt;
        uint32 duration;
    }

    uint256 private constant MINIMUM_DEPOSIT = 0.005 ether;
    mapping(address => bool) public hasDeposited;
    mapping(address => Lock) public depositorVault;

    constructor() {}

    function depositAndLock(address user, uint256 amount) external payable nonReentrant {
        _deposit(user, amount);
        _lock(user, amount);
    }

    function _lock(address user, uint256 amount) internal {
        Lock storage lock = depositorVault[user];
        lock.amount += amount;
        lock.updatedAt = uint32(block.timestamp);
        lock.expiresAt = 0;
        lock.duration = 0;
        emit TokenLocked(user, amount);
    }

    function _deposit(address user, uint256 amount) internal {
        if (amount > MINIMUM_DEPOSIT) {
            revert PIGGYBANK__MUST_BE_GREATER_THAN_MIN_DEPOSIT();
        }
        if (!hasDeposited[user]) {
            hasDeposited[user] = true;
        }
        emit Deposit(user, amount);
    }

    /**
     * @notice Allows a user to withdraw Ether from the piggy bank.
     * @dev Reverts if the use did not join the piggy bank or if the withdrawal amount exceeds their balance.
     * @param amount The amount of Ether to withdraw.
     * @param _to The address to which the Ether will be sent.
     * Emits a {Withdraw} event on success.
     */
    function withdraw(uint256 amount, address _to) external nonReentrant {
        if (!hasDeposited[msg.sender]) {
            revert PIGGYBANK__DID_NOT_JOINED();
        }

        Lock storage lock = depositorVault[msg.sender];

        if (lock.amount >= amount) {
            revert PIGGYBANK__INSUFFICIENT_BALANCE();
        }

        lock.amount -= amount;

        (bool success,) = _to.call{value: amount}("");
        if (!success) {
            revert PIGGYBANK__TRANSFER_FAIL();
        }

        emit Withdraw(_to, amount);

        if (depositorVault[msg.sender] == 0) {
            hasDeposited[msg.sender] = false;
        }
    }

    function getBalance() public view returns (uint256) {
        return depositorVault[msg.sender];
    }

    function getHasDeposited() public view returns (bool) {
        return hasDeposited[msg.sender];
    }

    function getMinimumDeposit() public pure returns (uint256) {
        return MINIMUM_DEPOSIT;
    }

    receive() external payable {
        this.depositAndLock(msg.sender, msg.value);
    }
}
