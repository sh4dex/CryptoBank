//SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

// Functions:
    //1. Deposit ether
    //2. Withdraw ether

//Rules:
    //1. Multiuser
    //2. Only can deposit ether
    //3. User can only withdraw previusly depsited ether
    //4. Max deposit
    //5. Max deposit modified by owner

contract CryptoBank{

    address public owner;
    uint256 public maxDeposit;
    mapping(address => uint) public balance;

    event EtherDeposited(uint256 ethAmount_, address account_);

    constructor (uint256 maxDeposit_) {
        owner = msg.sender;
        maxDeposit = maxDeposit_;
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
        emit EtherDeposited(msg.value, msg.sender);
    } 

    function withdraw(uint256 amount_) public {
        require(amount_ <= balance[msg.sender], "not enough eth to transfer");
    
        balance[msg.sender] -= amount_;

        (bool successs, ) = msg.sender.call{value : amount_}("");
        require(successs, "Transaction failed")
    }

}