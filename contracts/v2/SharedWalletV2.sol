pragma solidity ^0.8.13;
/* 
* author: DaniloDughetti
* github: https//github.com/DaniloDughetti
* date: 13/04/2022
* SPDX-License-Identifier: MIT
*/

import "./OwnerV2.sol";
import "./WalletV2.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract SharedWalletV2 is OwnerV2, WalletV2 {
    
    using SafeMath for uint;
    mapping(address => uint) public wallets;
    mapping(address => AllowanceReceiver) public allowanceReceivers;
    uint public balance;

    event MoneyReceived(address, uint);
    event AllowanceReceiverInfo(AllowanceReceiver);

    function fullWithdraw(address payable _to, uint _amount) public OnlyOwner Pausable {
        require(_amount <= balance, "Operation denied: Not enough balance");
        _to.transfer(_amount);
    }

    function myBalance() public view Pausable returns(uint) {
        return wallets[msg.sender];
    }

    /*
    * Generic deposit function
    */
    function receiveMoney() public payable Pausable {
        assert(msg.value.add(balance) >= balance);
        balance = balance.add(msg.value);
        wallets[msg.sender] = wallets[msg.sender].add(msg.value);
        emit MoneyReceived(msg.sender, msg.value);
    }

    /*Settings up allowanceReceiver informations
    * _to: receiver address
    * _timeToWait: timestamp between now and next time receiver can redeem money
    * _allowance: amount of money to withdraw
    */
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

    //Check if msg.sender is capable to edit allowanceReceiver informations in order to prevent malicious edits
    function isAllowanceReceiverOwner(address _sender, address _receiver) view private returns(bool) {
        return (!allowanceReceivers[_receiver].isPresent || allowanceReceivers[_receiver].from == _sender);
    }

    //Check if allowanceReceiver is present and if msg.sender balance is greater than allowance
    function isAllowanceReceiverBalanceNegative(address _sender, address _receiver) view private returns(bool) {
        return (!allowanceReceivers[_receiver].isPresent || wallets[_sender] <= allowanceReceivers[_receiver].allowance);
    }

    function withdrawAllowance() public payable {
        //Check if allowanceReceiver exists
        require(allowanceReceivers[msg.sender].isPresent, "Operation denied: You are not present in allowance accounts");
        require(!isAllowanceReceiverBalanceNegative(allowanceReceivers[msg.sender].from, msg.sender), "Operation denied: Balance insufficent");
        require(checkTransferEligible(allowanceReceivers[msg.sender]), "Operation denied: According to your allowanceReceiver information this is not withdraw time");
        //Update sender balance
        wallets[allowanceReceivers[msg.sender].from] = 
        wallets[allowanceReceivers[msg.sender].from].sub(allowanceReceivers[msg.sender].allowance);
        //Update timestamp
        allowanceReceivers[msg.sender].transferTimestamp.push(block.timestamp);
        //Update balance
        balance = balance.sub(allowanceReceivers[msg.sender].allowance);
        //in transfer the method caller is the receiver of the money
        payable(msg.sender).transfer(allowanceReceivers[msg.sender].allowance);
    }

    function getAllowanceReceiver() public {
        emit AllowanceReceiverInfo(allowanceReceivers[msg.sender]);
    }
 
    receive() external payable {
        receiveMoney();
    }
}