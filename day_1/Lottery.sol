// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// User deposit money
// 1 ether, 1 ticket
// A = 100
// B = 50
// A = 100/150 = 2/3 = 66%
// deposit, withdraw, drawWinner
contract Lottery {
    address owner;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public players;
    uint256 public playerIndex;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        require(msg.value >= 0.1 ether, "Minimum buy in is 0.1 ether");
        uint256 amount = msg.value;

        if (balances[msg.sender] == 0)
            players[playerIndex++] = msg.sender;
        balances[msg.sender] += amount;
    }

    // Get random winner
    // Count sum
    // Transfer funds
    // Update state
    function drawWinner() public returns(uint256) {
        require(playerIndex > 0, "No players");

        uint256 winningIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % playerIndex;

        address winner = players[winningIndex];
        uint256 winnerBalance = balances[winner];

        // Let's say I want to take 50% profit from this lottery
        // If A deposit 50 & B deposit 50
        // A wins, A will take back their bet amount + 50% of the remaining pool
        // A will earn 50 + 25 (50% of 50)
        // The other 50% we earn as a fee
        uint256 sum = 0;
        for (uint256 i = 0; i < playerIndex; i++) {
            address player = players[i];
            sum += balances[player];
            balances[player] = 0;
        }

        playerIndex = 0;

        // Count the additional earnings
        uint256 remaining = sum - winnerBalance;
        uint256 earnings = remaining / 2;

        (bool success, ) = winner.call{value: winnerBalance + earnings}("");
        require(success, "Transfer failed.");
        return winnerBalance;
    }

    function withdraw() public {
        require(owner == msg.sender, "Not owner");
        
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}