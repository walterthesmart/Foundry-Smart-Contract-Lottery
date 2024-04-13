// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
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
            callbackGasLimit: 500000 //500,000 gas
        });
    }

    function getBNBConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.01 ether, //0.01 BNB
            interval: 30,
            vrfCoordinator: 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f,
            gasLane: 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314,
            subscriptionId: 0, //Update this with our subId
            callbackGasLimit: 500000 //500,000 gas
        });
    }

    function getAVAXConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether, //0.01 AVAX
            interval: 30,
            vrfCoordinator: 0x2eD832Ba664535e5886b75D64C46EB9a228C2610,
            gasLane: 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61,
            subscriptionId: 0, //Update this with our subId
            callbackGasLimit: 500000 //500,000 gas
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
        vm.stopBroadcast();
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314,
            subscriptionId: 0, //our script will add this
            callbackGasLimit: 500000 //500,000 gas
        });
    }
        
        
}
    