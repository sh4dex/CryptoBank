// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {CryptoBank} from  "../src/CryptoBank.sol";

contract CryptoBankDeploy is Script {

    function run()  external {
        vm.startBroadcast();

        CryptoBank cryptoBank = new CryptoBank(10 ether, msg.sender);

        vm.stopBroadcast();
    }
}
