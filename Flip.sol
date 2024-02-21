// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./library.sol";

contract Flip {

    address owner;

    constructor(address user){
        owner = user;
    }

    uint256 public probWin = 500;
    uint256 public probLose = 1000 - probWin;
    uint256 public probLoseGivenWin; // Initial conditional probability factor
    uint256 public looseCount = 0;
    uint256 public winCount = 0;
    bool[] public streakArray;
    
    // State variable to store the current coin value
    // Event emitted when the coin value is updated
    // event CoinFlipped(address indexed owner, coin.Coin newCoin, coin.Coin currentCoin);
    // event CoinLanded(address indexed User, uint256 winStreak);

    using coin for coin.Coin;
    coin.Coin public currentCoin;

    mapping(address => uint256) public usertoWinCount;
    mapping(address => uint256) public usertoLooseCount;

    function currentWinStreak() public view returns (uint256) {
        uint256 winStreak = 0; // Start with no win streak

        for (uint256 i = streakArray.length - 1; i >= 0; i--) { // Iterate backwards through flips
            if (streakArray[i]) { // If it's a win (heads), increment streak
                winStreak++;
            } else { // If it's a loss (tails), break and return current streak
                break;
            }
        }
        return winStreak;
    }

    function sudoProbability() public view returns (uint256) {
        bytes32 hash = keccak256(abi.encodePacked(block.number, block.timestamp, blockhash(block.number - 1),probWin, probLose, looseCount, winCount, owner));
        // Convert the hash to a uint8 value (0 or 1)
        uint8 result = uint8(uint256(hash)) % 2;
        uint256 prob_Win = probWin;
        uint256 prob_Lose = 1000 - prob_Win;
        if (result == uint256(currentCoin)) {
                // Player wins
                prob_Lose = prob_Lose + (prob_Win * probLoseGivenWin)/100;
                prob_Win = 1000 - prob_Lose;
        } else {
                // Player loses
                prob_Win = prob_Win + (prob_Lose * probLoseGivenWin)/100;
                prob_Lose = 1000 - prob_Win;
            }

        // emit CoinFlipped(owner, currentCoin);
        return prob_Win;
    }

    // Function to get the current coin value
    function getCurrentCoin() external view returns (coin.Coin) {
        return currentCoin;
    }

    // Function to generate a pseudo-random floating-point number between 0 to 100
    function generateRandomFloat() public view returns (uint256) {
        bytes32 hash = keccak256(abi.encodePacked(block.number, block.timestamp, blockhash(block.number - 1),probWin, probLose, looseCount, winCount, owner));

        // Convert the hash to a uint256 value and normalize it to be between 0 and 1
        uint256 randomNumber = uint256(hash) % 1000000;
        uint256 randomFloat = uint256(randomNumber) / 1000;
        return randomFloat;
    }

    function oneXwins(coin.Coin _newCoin, uint256 prob_LoseGivenWin) public returns(bool, uint256){
        currentCoin = _newCoin;
        probLoseGivenWin = prob_LoseGivenWin;
        uint256 psudoWinProb = sudoProbability();
        uint256 actualProb = generateRandomFloat();
        bool results = actualProb < psudoWinProb;
        streakArray.push(results);
        uint256 winStreak = currentWinStreak();

        if(results == true){
            // Player wins
            probLose = probLose + (probWin * probLoseGivenWin)/100;
            probWin = 1000 - probLose;
            usertoWinCount[owner] = winCount++;
            // uint256 winAmount = amount + amount;
            // payable(msg.sender).transfer(winAmount);

            // Adjust conditional probability factor for winning
            // prob_LoseGivenWin += 5; // You can adjust this value based on your desired dynamics
        } else {
            // Player loses
            probWin = probWin + (probLose * probLoseGivenWin)/100;
            probLose = 1000 - probWin;
            // Reset conditional probability factor for losing
            // prob_LoseGivenWin = 20;
            usertoWinCount[owner] = looseCount++;
        }
        // currentWinStreak();
        return (results,winStreak) ;
    }

    function fiveXwins(coin.Coin _newCoin, uint256 prob_LoseGivenWin) public returns(bool, uint256){
        currentCoin = _newCoin;
        probLoseGivenWin = prob_LoseGivenWin;
        uint256 psudoWinProb = (sudoProbability()/5);
        uint256 actualProb = generateRandomFloat();
        bool results = actualProb < psudoWinProb;
        streakArray.push(results);
        uint256 winStreak = currentWinStreak();
        if(results){
            // Player wins
            probLose = probLose + (probWin * probLoseGivenWin)/100;
            probWin = 1000 - probLose;
            usertoWinCount[owner] = winCount++;
            // uint256 winAmount = amount + amount;
            // payable(msg.sender).transfer(winAmount);

            // Adjust conditional probability factor for winning
            // prob_LoseGivenWin += 5; // You can adjust this value based on your desired dynamics
        } else {
            // Player loses
            probWin = probWin + (probLose * probLoseGivenWin)/100;
            probLose = 1000 - probWin;
            // Reset conditional probability factor for losing
            // prob_LoseGivenWin = 20;
            usertoWinCount[owner] = looseCount++;

        }
        return (results,winStreak);
    }

    function tenXwins(coin.Coin _newCoin, uint256 prob_LoseGivenWin) public returns(bool, uint256){
        currentCoin = _newCoin;
        probLoseGivenWin = prob_LoseGivenWin;
        uint256 psudoWinProb = (sudoProbability()/10);
        uint256 actualProb = generateRandomFloat();
        bool results = actualProb < psudoWinProb;
        streakArray.push(results);
        uint256 winStreak = currentWinStreak();
        if(results){
            // Player wins
            probLose = probLose + (probWin * probLoseGivenWin)/100;
            probWin = 1000 - probLose;
            usertoWinCount[owner] = winCount++;
            // uint256 winAmount = amount + amount;
            // payable(msg.sender).transfer(winAmount);

            // Adjust conditional probability factor for winning
            // prob_LoseGivenWin += 5; // You can adjust this value based on your desired dynamics
        } else {
            // Player loses
            probWin = probWin + (probLose * probLoseGivenWin)/100;
            probLose = 1000 - probWin;
            // Reset conditional probability factor for losing
            // prob_LoseGivenWin = 20;
            usertoWinCount[owner] = looseCount++;

        }
        return (results,winStreak);
    }
    
}