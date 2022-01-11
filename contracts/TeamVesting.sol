// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./TokenVesting.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TeamVesting is Context, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address[] public teamAddresses;
    mapping (address => TokenVesting) public vestingContracts;
    IERC20 public token;
    bool public vestedOnce;
    uint256 public start;
    uint256 public cliffDuration;
    uint256 public duration;

    constructor(IERC20 _token, uint256 _start, uint256 _cliffDuration, uint256 _duration) public {
        token = _token;
        start = _start;
        cliffDuration = _cliffDuration;
        duration = _duration;
    }

    function getTeamAddresses() public view returns (address[] memory) {
        return teamAddresses;
    }

    function addTeamMember(address addr) public onlyOwner {
        require(!vestedOnce, "TeamVesting: You can add team members only before the vesting starts");
        require(addr != address(0), "TeamVesting: Provided address is not valid");
        teamAddresses.push(addr);
        vestingContracts[addr] = new TokenVesting(addr, start, cliffDuration, duration, false);
        vestingContracts[addr].transferOwnership(_msgSender());
    }

    function vest() public onlyOwner {
        require(!vestedOnce, "TeamVesting: You can vest tokens only once");
        require(teamAddresses.length > 0, "TeamVesting: The team needs to have at least one member");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TeamVesting: You should transfer some tokens first");
        require(amount.mod(teamAddresses.length) == 0, "TeamVesting: Indivisible number of tokens");

        uint256 perMember = amount.div(teamAddresses.length);
        for (uint i = 0; i < teamAddresses.length; i++) {
            address addr = teamAddresses[i];
            token.safeTransfer(address(vestingContracts[addr]), perMember);
        }
        vestedOnce = true;
    }

    function remaining(address addr) public view returns (uint256) {
        require(vestedOnce, "TeamVesting: You should vest some tokens first");
        require(address(vestingContracts[addr]) != address(0), "TeamVesting: Provided address is not a team member");
        return token.balanceOf(address(vestingContracts[addr]));
    }

    function vested(address addr) public view returns (uint256) {
        require(vestedOnce, "TeamVesting: You should vest some tokens first");
        require(address(vestingContracts[addr]) != address(0), "TeamVesting: Provided address is not a team member");
        return vestingContracts[addr].vestedAmount(token);
    }

    function releasable(address addr) public view returns (uint256) {
        require(vestedOnce, "TeamVesting: You should vest some tokens first");
        require(address(vestingContracts[addr]) != address(0), "TeamVesting: Provided address is not a team member");
        return vestingContracts[addr].releasableAmount(token);
    }

    function released(address addr) public view returns (uint256) {
        require(vestedOnce, "TeamVesting: You should vest some tokens first");
        require(address(vestingContracts[addr]) != address(0), "TeamVesting: Provided address is not a team member");
        return vestingContracts[addr].released(address(token));
    }

    function release(address addr) public {
        require(vestedOnce, "TeamVesting: You should vest some tokens first");
        require(address(vestingContracts[addr]) != address(0), "TeamVesting: Provided address is not a team member");
        vestingContracts[addr].release(token);
    }

    function releaseAll() public {
        require(vestedOnce, "TeamVesting: You should vest some tokens first");
        for (uint i = 0; i < teamAddresses.length; i++) {
            address addr = teamAddresses[i];
            if(releasable(addr) > 0) {
                release(addr);
            }
        }
    }
}
