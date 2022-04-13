pragma solidity ^0.8.13;
/* 
* author: DaniloDughetti
* github: https//github.com/DaniloDughetti
* date: 13/04/2022
* SPDX-License-Identifier: MIT
*/

import "./Owner.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract SharedWallet is Owner {
    
    using SafeMath for uint;
    mapping(address => uint) public wallets;
    uint public balance;

    event MoneyReceived(address, uint);

    function fullWithdraw(address payable _to, uint _amount) public OnlyOwner {
        require(_amount <= balance, "Operation denied: Not enough balance");
        _to.transfer(_amount);
    }

    function myBalance() public view returns(uint) {
        return wallets[msg.sender];
    }

    function receiveMoney() public payable {
        assert(msg.value + balance >= balance);
        balance.add(msg.value);
        wallets[msg.sender].add(msg.value);
        emit MoneyReceived(msg.sender, msg.value);
    }

    receive() external payable {
        receiveMoney();
    }
}