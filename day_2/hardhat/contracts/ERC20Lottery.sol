// SPDX-License-Identifier: GPL-3.0

import "./GameToken.sol";

pragma solidity ^0.8.0;

/**
* User deposits money
* The amount deposited is the winning chance
* A = 100
* B = 50
* Winning chance of A = 100/150 = 2/3 = 66.66%
* Someone will execute the lucky draw selection
* At the end of the drawing, winner earns 50% of total pool on top of their deposit
* Remaining 50% goes to us
*/
contract Lottery {
    address owner;
    mapping(address => uint256) balances;
    mapping(uint256 => address) players;
    mapping(uint256 => address) tickets;
    uint256 public ticketIndex;
    uint256 public playerIndex;
    GameToken gameToken;

    event Winner(address winner, uint256 winAmount);
    event TicketsPurchased(address buyer, uint256 amount);

    constructor(GameToken _gameToken) {
        owner = msg.sender;
        gameToken = _gameToken;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Not owner");
        _;
    }
    
    function buyTickets(uint256 ticketsPurchased) public {
        gameToken.transferFrom(msg.sender, address(this), ticketsPurchased);
        tickets[ticketIndex] = msg.sender;
        ticketIndex += ticketsPurchased;

        // Check if player balance is 0. If 0, they have not been counted for yet
        // If more than 0, they were already counted for, hence we should not increment the index
        if (balances[msg.sender] == 0) {
            // First we need to set the index of the player
            players[playerIndex++] = msg.sender;
        }
        balances[msg.sender] += ticketsPurchased;

        emit TicketsPurchased(msg.sender, ticketsPurchased);
    }

    function getTicketOwner(uint256 index) public view returns(address) {
        require(index < ticketIndex, "Ticket Doesn't Exist");
        for (uint256 i = index; i >= 0; i--) {
            if (tickets[i] != address(0))
                return tickets[i];
        }
        return tickets[0];
    }

    function drawWinner() public {
        require(playerIndex > 0, "No players");

        uint256 winningIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % ticketIndex;
        
        // Get winner details
        address winner = getTicketOwner(winningIndex);
        uint256 winnerBalance = balances[winner];

        // Count sum
        uint256 sum = 0;
        for (uint256 i = 0; i < playerIndex; i++) {
            address player = players[i];
            sum += balances[player];
            balances[player] = 0;
        }
        // Reset state
        playerIndex = 0;

        // Count earnings
        uint256 earnings = (sum - winnerBalance) / 2;

        // Send funds
        bool success = gameToken.transfer(winner, winnerBalance + earnings);
        require(success, "Transfer failed.");

        emit Winner(winner, winnerBalance + earnings);
    }

    // This function withdraws the ether balance, not the tickets
    function withdraw() public onlyOwner {
        // Get the payable owner address
        address payable to = payable(owner);

        // Send funds to owner
        (bool success, ) = to.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}