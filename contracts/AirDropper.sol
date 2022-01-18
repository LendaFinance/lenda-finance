// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract AirDropper is Context, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint16 public arrayLimit = 120;

    function() external payable {}

    function changeTreshold(uint16 _newLimit) public onlyOwner {
        arrayLimit = _newLimit;
    }

    function airdropToken(address _token, address[] memory _recipients, uint256[] memory _balances) public payable {
        require(_recipients.length <= arrayLimit, "AirDropper: Too many recipients");
        IERC20 token = IERC20(_token);
        require(token.allowance(_msgSender(), address(this)) > 0, "AirDropper: Not enough allowance");

        for (uint8 i = 0; i < _recipients.length; i++) {
            token.safeTransferFrom(_msgSender(), _recipients[i], _balances[i]);
        }
    }

    function airdropNative(address payable[] memory _recipients, uint256[] memory _balances) public payable {
        require(_recipients.length <= arrayLimit, "AirDropper: Too many recipients");

        for (uint8 i = 0; i < _recipients.length; i++) {
            _recipients[i].transfer(_balances[i]);
        }
    }

    function claimTokens(address _token) public onlyOwner {
        address payable _owner = address(uint160(owner()));
        if (_token == address(0)) {
            _owner.transfer(address(this).balance);
        } else {
            IERC20 token = IERC20(_token);
            uint256 balance = token.balanceOf(address(this));
            token.safeTransfer(owner(), balance);
        }
    }
}
