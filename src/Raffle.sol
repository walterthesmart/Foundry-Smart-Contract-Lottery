// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/** 
 * @title Raffle
 * @author Nwaugo Walter
 * @notice A simple raffle contract that allows users to buy tickets and win prizes
 * @dev Implements Chainlink VRFv2
 */

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2{

    error Raffle__NotEnoughEthSent();
    error Raffle__NotEnoughTimePassed();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpKeepNotNeeded(uint256 balance, uint256 players, uint256 state);


    /**Type declarations */
    enum RaffleState {
        OPEN,
        CALCULATING} 

    //***State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;     // @dev The interval at which the raffle is run
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private  s_players;
    uint256 private s_lastTimeStamp;
    RaffleState private s_raffleState;

    /**Events */
    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinator)
        {
        i_entranceFee = entranceFee;
        i_interval = interval; 
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // Enter the raffle
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
        if (s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }
    }
    // when is th ewinner supposed to be picked?
    /**
     * @dev This function is called by the automation contract to check if the raffle needs to be run.
     * The following should be true for this return to run
     * 1. The time interval has passed between raffle runs
     * 2. The raffle is in an OPEN state
     * 3. The contract has ETH(aka, players)
     * 4. (Implicit) The subscription is funded with LINK
     */
    function checkUpKeep(bytes memory /* checkData */) public view returns (bool upKeepNeeded, bytes memory /*performData*/) {
        // Check if the raffle needs to be run
        // check to se if enough time has passed
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upKeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function performUpKeep(bytes calldata /* performData */) external {
        (bool upKeepNeeded, ) = checkUpKeep("");
        if(!upKeepNeeded){
            revert Raffle__UpKeepNotNeeded(
            address(this).balance,
            s_players.length,
            uint256(s_raffleState)
            );
        }
        // Pick the winner
        s_raffleState = RaffleState.CALCULATING;
        // Reqesft a random number from the Chainlink VRF
        // Pick a winner
        i_vrfCoordinator.requestRandomWords(
            i_gasLane, //gas lane
            i_subscriptionId, //ID funded with Link
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS //number of random numbers to return
        );
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords) internal override {
        // Pick a winner
        uint256 IndexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[IndexOfWinner];
        s_raffleState = RaffleState.OPEN;
        (bool success, ) = winner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(winner);
    }

    //***Getter functions */
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns(RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns(address) {
        return s_players[indexOfPlayer];
    }
}