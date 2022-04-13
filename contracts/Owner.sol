pragma solidity ^0.8.13;
/* 
* author: DaniloDughetti
* github: https//github.com/DaniloDughetti
* date: 13/04/2022
* SPDX-License-Identifier: MIT
*/
contract Owner {

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "Permission denied: Only owner can execute this function");
        _;
    }
}