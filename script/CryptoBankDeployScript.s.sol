// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

// import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {CryptoBank} from "../src/CryptoBank.sol";

contract CryptoBankDeploy is Script {
    //TODO: Deploy on testnet
    function run() external {
        vm.startBroadcast();

        CryptoBank cryptoBank = new CryptoBank(10 ether, msg.sender);

        vm.stopBroadcast();
    }
}
