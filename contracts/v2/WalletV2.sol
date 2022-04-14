pragma solidity ^0.8.13;
/* 
* author: DaniloDughetti
* github: https//github.com/DaniloDughetti
* date: 13/04/2022
* SPDX-License-Identifier: MIT
*/
contract WalletV2 {

    struct AllowanceReceiver {
        address payable from;
        uint allowance;
        uint timeToWait;
        uint[] transferTimestamp;
        bool isPresent;
    }

    /*
    * Verify if current time (block.timestamp) is greater time timeToWait
    */
    function checkTransferEligible(AllowanceReceiver memory _allowanceReceiver) internal view returns(bool) {
        return (_allowanceReceiver.transferTimestamp.length == 0 || 
        _allowanceReceiver.transferTimestamp[_allowanceReceiver.transferTimestamp.length] - block.timestamp >= _allowanceReceiver.timeToWait);
    }
}