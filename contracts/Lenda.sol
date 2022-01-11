// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract Lenda is ERC20Capped, ERC20Burnable, ERC20Detailed {
    constructor(uint256 initial, uint256 cap, uint8 decimals)
        ERC20Detailed("Lenda", "LENDA", decimals)
        ERC20Capped(cap * (uint256(10) ** uint256(decimals)))
        public
    {
        _mint(msg.sender, initial * (uint256(10) ** uint256(decimals)));
    }
}
