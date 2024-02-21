// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Flip.sol";
import "./library.sol";

contract factory {
    IERC20 token;
    address private owner;
    uint256 initalBalance = 10000;

    constructor() {
        token = IERC20(0xD3D083464D63a6a0d78a0DdE1F804e7233e8d977);
        // initalBalance = msg.value;
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event CoinFlipped(address indexed owner, coin.Coin newCoin, bool value);
    event CoinStreak(address indexed User, uint256 winStreak);

    function updateInitalBalance(uint256 amount) public OnlyOwner {
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "Not enough allowance"
        );
        token.transferFrom(msg.sender, address(this), amount);
        initalBalance = initalBalance + amount;
    }

    function GetUserTokenBalance(address user) public view returns (uint256) {
        return token.balanceOf(user);
    }

    function GetAllowance() public view returns (uint256) {
        return token.allowance(msg.sender, address(this));
    }

    Flip[] public UserArray;

    uint256 totalHouseFlips;
    uint256 public currentBalance;
    uint256 public probLoseGivenWin = 20;
    // bool value;
    // uint256 public winStreak;

    enum Multiplier {
        One,
        Five,
        Ten
    }

    using coin for coin.Coin;
    coin.Coin public currentCoin;

    mapping(address => address) public userAddressToContractAddress;

    function createflips() public {
        Flip userFlip = new Flip(address(msg.sender));
        UserArray.push(userFlip);
        userAddressToContractAddress[msg.sender] = address(userFlip);
    }

    function GetContractTokenBalance() public OnlyOwner returns (uint256) {
        currentBalance = token.balanceOf(address(this));
        return currentBalance;
    }

    function changeProb() public {
        if (currentBalance < ((initalBalance * 60) / 100)) {
            probLoseGivenWin += 5;
        }
        if (currentBalance > ((initalBalance * 120) / 100)) {
            probLoseGivenWin = 20;
        }
    }

    function flipaCoin(
        Multiplier _multi,
        uint256 amount,
        coin.Coin _newCoin
    ) public returns (bool, uint256) {
        require(amount > 0, "amount less than zero");
        require(currentBalance > amount, "current Balance is less than amount");
        currentCoin = _newCoin;
        address flipContract = userAddressToContractAddress[msg.sender];
        Flip flip = Flip(flipContract);
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "Not enough allowance"
        );
        token.transferFrom(msg.sender, address(this), amount);
        currentBalance = currentBalance + amount;
        bool value;
        uint256 winStreak;
        if (Multiplier.One == _multi) {
            //call oneXwins
            (value, winStreak) = flip.oneXwins(currentCoin, probLoseGivenWin);
            if (value) {
                require(token.balanceOf(address(this)) >= amount);
                currentBalance = currentBalance - (2 * amount);
                token.transfer(msg.sender, (2 * amount));
                changeProb();
            }
        }
        if (Multiplier.Five == _multi) {
            // call fiveXWins
            (value, winStreak) = flip.fiveXwins(currentCoin, probLoseGivenWin);
            if (value) {
                require(token.balanceOf(address(this)) >= amount);
                currentBalance = currentBalance - (5 * amount);
                token.transfer(msg.sender, (5 * amount));
                changeProb();
            }
        }
        if (Multiplier.Ten == _multi) {
            // call tenXwins
            (value, winStreak) = flip.tenXwins(currentCoin, probLoseGivenWin);
            if (value) {
                require(token.balanceOf(address(this)) >= amount);
                currentBalance = currentBalance - (10 * amount);
                token.transfer(msg.sender, (10 * amount));
                changeProb();
            }
        }
        emit CoinFlipped(msg.sender, _newCoin, value);
        emit CoinStreak(msg.sender, winStreak);
        return (value, winStreak);
    }

    // call once a day
    function withdraw() external {
        require(
            currentBalance > (initalBalance * 2),
            "balance is 200% of initalBalance"
        );
        uint256 amount = ((currentBalance * 30) / 100); //30% of currentBalance
        require(amount > 0);
        // (bool sent, ) = address(this).call{value: amount}("");
        token.transfer(owner, amount);
        // require(sent, "failed");
        initalBalance = initalBalance - amount;
    }

    function withdrawAll() external OnlyOwner {
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "balnace is 0");
        // (bool sent, ) = address(this).call{value: amount}("");
        token.transfer(owner, amount);
        // require(sent, "failed");
    }

    function xxx(
        Multiplier _multi,
        uint256 amount,
        coin.Coin _newCoin
    ) public returns (bool, uint256, bool, bool, bool) {
        require(amount > 0, "amount less than zero");
        currentCoin = _newCoin;
        address flipContract = userAddressToContractAddress[msg.sender];
        Flip flip = Flip(flipContract);
        bool value;
        uint256 winStreak;
        // require(token.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        // token.transferFrom(msg.sender, address(this), amount);
        (value, winStreak) = flip.oneXwins(currentCoin, probLoseGivenWin);
        bool val1 = Multiplier.One == _multi;
        bool val2 = Multiplier.Five == _multi;
        bool val3 = Multiplier.Ten == _multi;
        return (value, winStreak, val1, val2, val3);
    }

    function xx(
        Multiplier _multi,
        uint256 amount,
        coin.Coin _newCoin
    ) public returns (bool, uint256) {
        require(amount > 0, "amount less than zero");
        currentCoin = _newCoin;
        address flipContract = userAddressToContractAddress[msg.sender];
        Flip flip = Flip(flipContract);
        // require(token.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        // token.transferFrom(msg.sender, address(this), amount);
        bool value;
        uint256 winStreak;

        if (Multiplier.One == _multi) {
            //call oneXwins
            (value, winStreak) = flip.oneXwins(currentCoin, probLoseGivenWin);

            if (value) {
                // require (token.balanceOf(address(this)) >= amount);
                // currentBalance = currentBalance - (2 * amount);
                // token.transferFrom(address(this), msg.sender, amount);
                // return (value, winStreak);
            }
        }
        if (Multiplier.Five == _multi) {
            // call fiveXWins
            (value, winStreak) = flip.fiveXwins(currentCoin, probLoseGivenWin);
            if (value) {
                // require (token.balanceOf(address(this)) >= amount);
                // currentBalance = currentBalance - (5 * amount);
                // token.transferFrom(address(this), msg.sender, amount);
                // return (value, winStreak);
            }
        }
        if (Multiplier.Ten == _multi) {
            // call tenXwins
            (value, winStreak) = flip.tenXwins(currentCoin, probLoseGivenWin);
            if (value) {
                // require (token.balanceOf(address(this)) >= amount);
                // currentBalance = currentBalance - (10 * amount);
                // token.transferFrom(address(this), msg.sender, amount);
                // return (value, winStreak);
            }
        }
        // emit CoinFlipped(owner, currentCoin);
        emit CoinFlipped(msg.sender, _newCoin, value);
        emit CoinStreak(msg.sender, winStreak);
        return (value, winStreak);
    }
}
