// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// dummy sushi token contract 

contract Sushi is ERC20 {

    address public sushibarContractAddress;
    address owner;

    constructor() ERC20("SushiToken", "SUSHI") {
        owner = msg.sender;
    }

    // mints 'amount' sushi tokens to 'user' 
    // any user can mint any number of sushi tokens. Used to test sushibar contract.
    // will provide approval to sushibar contract for all the sushi tokens minted.
    function mintSushi(address user, uint amount) external {
        _mint(user, amount);
        increaseAllowance(sushibarContractAddress, amount);
    }

    function setSushibarAddress(address _sushibarContract) external {
        require(msg.sender == owner, "only owner can access");
        sushibarContractAddress = _sushibarContract;
    } 

}