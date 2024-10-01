// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EDPOnboarding} from "../src/EDPOnboarding.sol";

contract DeployScript is Script {
    EDPOnboarding public edpOnboarding;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        edpOnboarding = new EDPOnboarding();

        vm.stopBroadcast();
    }
}
