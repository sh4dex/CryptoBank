//SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

/**
 * @title CryptoBank
 * @author Thomas Sorza (Sh4dex)
 * @notice Simple implementation of a Multi user crypto bank, smart contract act as a registry of the balances of each address,
 * It has funds limits for all addresses with hand made access control system for contract onwner.
 * Allow operations: Deposit & withdraw ether
 * NOTE: User can only withdraw previusly depsited ether
 */

contract CryptoBank {
    address public immutable I_OWNER;
    uint256 public depositLimit;
    bool private _locked;
    mapping(address => uint256) public balances;

    event EtherDeposited(uint256 indexed ethAmount_, address indexed account_);
    event EtherWithdrawn(uint256 indexed ethAmount_, address indexed userOrigin_);
    event EtherSent(uint256 indexed ethAmount_, address indexed userOrigin_, address indexed userDestination_);
    event MaxBalanceEdited(uint256 indexed newLimit_);

    /**
     * @dev modifier that execute the {_onlyOwner} function before proceed with other execution
     */
    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    /**
     * @dev modifier that executes the {_checkTransferAmount} function before proceed with other execution
     * @param amount_ amount to transfer
     */
    modifier checkTransferAmount(uint256 amount_) {
        _checkTransferAmount(amount_);
        _;
    }

    /**
     * @dev To avoid reentrancy attacks the contract manage a state with ´_locked´ where it should be not locked indicading
     * that the call is not in process, while call is in process do not allow to fire callbacks.
     * NOTE: if the fuction related with ´_´ reverts, ´_locked´ reverts too. (reverts to {false})
     */
    modifier nonReentrant() {
        require(!_locked, "Reentrant call");
        _locked = true;
        _;
        _locked = false;
    }

    /**
     * @dev checks if the amount is greater than zero and is on the balance of the msg.sender
     * @param amount_ amount to transfer (should be into the balance mapping)
     */
    function _checkTransferAmount(uint256 amount_) internal view {
        require(amount_ <= balances[msg.sender] && amount_ > 0, "not enough eth to transfer");
    }

    /**
     * @dev validate that the sender is contract owner
     */
    function _onlyOwner() internal view {
        require(msg.sender == I_OWNER, "Not Allowed!");
    }

    /**
     * @param depositLimit_ Initial deposit limit per user
     * @param admin_ Unique admin set at contract's deployment
     */
    constructor(uint256 depositLimit_, address admin_) {
        I_OWNER = admin_;
        depositLimit = depositLimit_;
    }

    /**
     * @dev deposit ether into it's account updating ´balances()´, only if ´depositLimit´ is not exceeded
     */
    function depositEther() external payable {
        require(msg.value > 0, "Deposit value can't be zero");
        require(balances[msg.sender] + msg.value <= depositLimit, "Max Balance reached, please withdraw.");
        balances[msg.sender] += msg.value;
        emit EtherDeposited(msg.value, msg.sender);
    }

    /**
     * Functions that indicates how to
     * @param amount_ amount to withdraw from own balance
     * @dev using {nonReentrant} to avoid Reentrancy attacks
     */
    function withdrawEther(uint256 amount_) public checkTransferAmount(amount_) nonReentrant(){
        balances[msg.sender] -= amount_;

        (bool success,) = msg.sender.call{value: amount_}("");
        require(success, "Transfer Failed!");

        emit EtherWithdrawn(amount_, msg.sender);
    }

    /**
     * @param newLimit_ new limit of funds per user
     * @dev Only owner can call this function
     */
    function modifyMaxLimit(uint256 newLimit_) external onlyOwner {
        require(newLimit_ > 0, "You can't set zero as new limit");
        depositLimit = newLimit_;
        emit MaxBalanceEdited(newLimit_);
    }

    /**
     * Send Ether from own balance to other user (address)
     * @param amount_  amount of eth to send
     * @param to_ receiver address
     */
    function sendEth(uint256 amount_, address to_) public checkTransferAmount(amount_) nonReentrant() {
        require(balances[to_] + amount_ <= depositLimit, "Max balance reached for receiver");
        balances[msg.sender] -= amount_;
        balances[to_] += amount_;

        (bool success,) = to_.call{value: amount_}("");
        require(success, "Transfer failed!");
        emit EtherSent(amount_, msg.sender, to_);
    }
}
