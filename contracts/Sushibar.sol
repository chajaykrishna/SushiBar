// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

// SushiBar is the coolest bar in town. You come in with some Sushi, and leave with more! The longer you stay, the more Sushi you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.
contract SushiBar is ERC20("SushiBar", "xSUSHI"){
    using SafeMath for uint256;
    IERC20 public sushi;
    //maps user to the staking timestamp
    mapping (address => uint) public userToStakingTimestamp;
    mapping (address => uint) public userToxSushi;
    mapping (address => uint) public userToUnStakedSushi;
    
    // Define the Sushi token contract
    constructor(IERC20 _sushi) public {
        sushi = _sushi;
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks Sushi and mints xSushi
    function enter(uint256 _amount) public {
        //record the staking time
        userToStakingTimestamp[msg.sender] = block.timestamp;
        // Gets the amount of Sushi locked in the contract
        uint256 totalSushi = sushi.balanceOf(address(this));
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // If no xSushi exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
            userToxSushi[msg.sender] += _amount;
        } 
        // Calculate and mint the amount of xSushi the Sushi is worth. The ratio will change overtime, as xSushi is burned/minted and Sushi deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalSushi);
            _mint(msg.sender, what);
            userToxSushi[msg.sender] += what;
        }
        // Lock the Sushi in the contract
        sushi.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unlocks the staked + gained Sushi and burns xSushi
    /** Time lock after staking:
    *2 days - 0% can be unstaked
    *2-4 days - 25% can be unstaked
    *4-6 days - 50% can be unstaked
    *6-8 days - 75% can be unstaked
    *
     */
    function leave(uint256 _share) public {

        uint stakedTime = block.timestamp - userToStakingTimestamp[msg.sender];
        require(stakedTime > 2 minutes, "cannot unstake sushi for the first 2days");

        uint256 totalSushiStaked = userToxSushi[msg.sender];
        uint256 totalUnstakedSushi = userToUnStakedSushi[msg.sender];
        require(balanceOf(msg.sender) >= _share, "insufficient funds");
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Sushi the xSushi is worth
        uint256 what = _share.mul(sushi.balanceOf(address(this))).div(totalShares);

        require(_unstakingCheck(stakedTime, totalSushiStaked, _share + totalUnstakedSushi), "cannot unstake the required amount of sushi");
        userToUnStakedSushi[msg.sender] += _share;
        _burn(msg.sender, _share);

        // calculate tax, deduct from the sushi and transfer the remaining.
        uint256 taxOnSushi = _calculateTax(stakedTime, what);
        console.log(taxOnSushi);
        sushi.transfer(msg.sender, what- taxOnSushi);

        // transfer taxOnSushi to rewards pool
        // sushi.transfer(rewardpoolAddress, taxOnSushi);
    }


    // calculating tax 
    function _calculateTax(uint256 _stakedTime, uint256 sushiAmount) internal pure returns(uint) {
         if(_stakedTime <= 4 days) {
            return (3 * (sushiAmount)).div(4);
        } 
        else if(_stakedTime <= 6 days) {
             return ( sushiAmount.div(2));
        }
        else if(_stakedTime <= 8 days) {
             return (sushiAmount).div(4);
        }
        else return 0;
    }

    /* function used by internal functions to check if the unstaking is possible
    *@param _stakedTime total staking time
    @param _totalStakedSushi total amount of sushi staked in the sushiBar contract.
    @param _share the amount of sushi user trying to unstake
    */ 
    function _unstakingCheck(uint256 _stakedTime, uint256 totalStakedSushi, uint256 _share) internal pure returns(bool success) {
        
        if(_stakedTime <= 4 minutes) {
            return (_share <= totalStakedSushi.div(4));
        } 
        else if(_stakedTime <= 6 minutes) {
             return (_share <= totalStakedSushi.div(2));
        }
        else if(_stakedTime <= 8 minutes) {
             return (_share <= (3 * (totalStakedSushi)).div(4));
        }
        else return true;
    }
}