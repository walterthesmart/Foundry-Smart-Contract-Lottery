// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address linkToken;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 97){
            activeNetworkConfig = getBNBConfig();
        }
        else if(block.chainid ==43113){
            activeNetworkConfig = getAVAXConfig();
        }
        else if(block.chainid == 421614){
            activeNetworkConfig = getArbSepEthConfig();
        }
        else if(block.chainid == 4002){
            activeNetworkConfig = getFantomConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, //Update this with our subId
            callbackGasLimit: 500000,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789 //500,000 gas
        });
    }

    function getBNBConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.01 ether, //0.01 BNB
            interval: 30,
            vrfCoordinator: 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f,
            gasLane: 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314,
            subscriptionId: 0, //Update this with our subId
            callbackGasLimit: 500000,
            linkToken: 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06 //500,000 gas
        });
    }

    function getAVAXConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //0.01 AVAX
            interval: 30,
            vrfCoordinator: 0x2eD832Ba664535e5886b75D64C46EB9a228C2610,
            gasLane: 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61,
            subscriptionId: 0, //Update this with our subId
            callbackGasLimit: 500000,
            linkToken: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846 //500,000 gas
        });
    }

    function getArbSepEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //0.01 AVAX
            interval: 30,
            vrfCoordinator: 0x50d47e4142598E3411aA864e08a44284e471AC6f,
            gasLane: 0x027f94ff1465b3525f9fc03e9ff7d6d2c0953482246dd6ae07570c45d6631414,
            subscriptionId: 0, //Update this with our subId
            callbackGasLimit: 500000,
            linkToken: 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E //500,000 gas
        });
    }

    function getFantomConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //0.01 AVAX
            interval: 30,
            vrfCoordinator: 0xbd13f08b8352A3635218ab9418E340c60d6Eb418,
            gasLane: 0x121a143066e0f2f08b620784af77cccb35c6242460b4a8ee251b4b416abaebd4,
            subscriptionId: 473, //Update this with our subId
            callbackGasLimit: 500000,
            linkToken: 0xfaFedb041c0DD4fA2Dc0d87a6B0979Ee6FA7af5F //500,000 gas
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)){
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether; //0.25 LINK
        uint96 gasPriceLink = 1e9; //1 gwei LINK
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314,
            subscriptionId: 0, //our script will add this
            callbackGasLimit: 500000,
            linkToken: address(link) //500,000 gas
        });
    }
        
        
}
    