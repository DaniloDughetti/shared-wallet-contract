pragma solidity ^0.8.13;
/* 
* author: DaniloDughetti
* github: https//github.com/DaniloDughetti
* date: 13/04/2022
* SPDX-License-Identifier: MIT
*/

import "./Owner.sol";
import "./Wallet.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract SharedWallet is Owner, Wallet {
    
    using SafeMath for uint;
    mapping(address => uint) public wallets;
    mapping(address => AllowanceReceiver) public allowanceReceivers;
    uint public balance;

    event MoneyReceived(address, uint);
    event AllowanceSent(address, uint);

    function fullWithdraw(address payable _to, uint _amount) public OnlyOwner Pausable {
        require(_amount <= balance, "Operation denied: Not enough balance");
        _to.transfer(_amount);
    }

    function myBalance() public view Pausable returns(uint) {
        return wallets[msg.sender];
    }

    function receiveMoney() public payable Pausable {
        assert(msg.value.add(balance) >= balance);
        balance = balance.add(msg.value);
        wallets[msg.sender] = wallets[msg.sender].add(msg.value);
        emit MoneyReceived(msg.sender, msg.value);
    }

    function setAllowanceReceiver(address payable _to, uint _timeToWait, uint _allowance) public {
        require(isAllowanceReceiverOwner(msg.sender, _to), "Operation denied: You are not the same address who created the allowed receiver");
        
        uint[] memory _transferTimestamp;
        allowanceReceivers[_to] = AllowanceReceiver({
            from: payable(msg.sender),
            timeToWait: _timeToWait,
            allowance: _allowance,
            transferTimestamp: _transferTimestamp,
            isPresent: true
        });
    }

    function isAllowanceReceiverOwner(address _sender, address _receiver) view private returns(bool) {
        return (!allowanceReceivers[_receiver].isPresent || allowanceReceivers[_receiver].from == _sender);
    }

    function isAllowanceReceiverBalanceNegative(address _sender, address _receiver) view private returns(bool) {
        return (!allowanceReceivers[_receiver].isPresent || wallets[_sender] <= allowanceReceivers[_receiver].allowance);
    }

    function withdrawAllowance() public {
        require(allowanceReceivers[msg.sender].isPresent, "Operation denied: You are not present in allowance accounts");
        require(!isAllowanceReceiverBalanceNegative(allowanceReceivers[msg.sender].from, msg.sender), "Operation denied: Balance insufficent");
        wallets[allowanceReceivers[msg.sender].from] = 
        wallets[allowanceReceivers[msg.sender].from].sub(allowanceReceivers[msg.sender].allowance);

        allowanceReceivers[msg.sender].transferTimestamp.push(block.timestamp);

        allowanceReceivers[msg.sender].from.transfer(allowanceReceivers[msg.sender].allowance);
    }
 
    receive() external payable {
        receiveMoney();
    }
}