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

    address public immutable I_OWNER;
    uint256 public depositLimit;
    mapping(address => uint256) public balances;

    event EtherDeposited(uint256 ethAmount_, address account_);
    event EtherWithdrawn(uint256 ethAmount_, address userOrigin_);
    event MaxBalanceEdited(uint256 newLimit_);

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == I_OWNER, "Not Allowed!");
    }

    constructor (uint256 depositLimit_, address admin_) {
        I_OWNER = admin_;
        depositLimit = depositLimit_;
    }

    function depositEther() external payable {
        require(balances[msg.sender] + msg.value <= depositLimit, "Max Balance reached, please withdraw.");
        require(msg.value >= 0, "Deposit value can't be zero");
        balances[msg.sender] += msg.value;
        emit EtherDeposited(msg.value, msg.sender);
    } 


    //TODO: Add reentrancy protection (locked state)
    function withdrawEther(uint256 amount_) public {
        require(amount_ <= balances[msg.sender] && amount_>0, "not enough eth to transfer");
    
        balances[msg.sender] -= amount_;

        (bool success, ) = msg.sender.call{value : amount_}("");
        require(success, "Transaction failed");

        emit EtherWithdrawn(amount_, msg.sender);
    }

    function modifyMaxBalance(uint256 newLimit_) external onlyOwner{
        depositLimit = newLimit_;
        emit MaxBalanceEdited(newLimit_);
    }


    //TODO: Send Ether to other user
}