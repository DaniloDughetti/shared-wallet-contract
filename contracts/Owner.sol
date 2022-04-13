pragma solidity ^0.8.13;
/* 
* author: DaniloDughetti
* github: https//github.com/DaniloDughetti
* date: 13/04/2022
* SPDX-License-Identifier: MIT
*/
contract Owner {

    address payable public owner;
    bool public isPaused;

    constructor() {
        owner = payable(msg.sender);
        isPaused = false;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "Permission denied: Only owner can execute this function");
        _;
    }

    modifier Pausable() {
        require(!isPaused, "Permission denied: Smart contract is paused");
        _;
    }

    function pauseSmartContract(bool _isPaused) public OnlyOwner {
        isPaused = _isPaused;
    }

}