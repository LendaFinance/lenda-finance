// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./Lenda.sol";

contract StakingLenda is Lenda, Ownable {
    using SafeMath for uint256;

    struct Unstake {
        uint256 timestamp;
        uint256 amount;
    }

    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    mapping(address => uint256) internal snapshots;
    mapping(address => Unstake) internal unstakes;

    uint256 public annualMintTarget;
    uint256 public cooldown;

    uint256 public totalUnstakes;
    uint256 public totalStakes;

    uint256 internal currentSnapshot;
    uint256 internal lastDistribution;

    constructor(uint256 _initial, uint256 _cap, uint8 _decimals, uint256 _annualMintTarget, uint256 _cooldown)
        Lenda(_initial, _cap, _decimals)
        public {
            annualMintTarget = _annualMintTarget;
            cooldown = _cooldown;
            lastDistribution = block.timestamp;
    }

    // This will make the token fully BEP20 compliant
    function getOwner() external view returns (address) {
        return owner();
    }

    function setCooldown(uint256 _cooldown) public onlyOwner {
        cooldown = _cooldown;
    }

    // ==================== Staking / Releasing stake ========== /

    function addStake(uint256 amount) public distributesReward {
        // Send tokens to the token address and add them as stake for sender
        _transfer(_msgSender(), address(this), amount);
        stakes[_msgSender()] = stakes[_msgSender()].add(amount);
        totalStakes = totalStakes.add(amount);
    }

    function stakeOf(address stakeholder) public view returns (uint256) {
        return stakes[stakeholder];
    }

    function requestUnstake(uint256 amount) public distributesReward {
        // Stake under cooldown can also be requested, since new requests invalidate old ones
        Unstake memory req = unstakes[_msgSender()];
        uint256 all = stakes[_msgSender()].add(req.amount);
        require(amount <= all, "StakingLenda: Requested more tokens than totally staked");

        // Creating a new request will invalidate the old one
        unstakes[_msgSender()] = Unstake(block.timestamp.add(cooldown), amount);
        totalUnstakes = totalUnstakes.sub(req.amount).add(amount);
        // Remove requested stake, so it doesn't bring rewards during the cooldown period
        stakes[_msgSender()] = all.sub(amount);
        totalStakes = totalStakes.add(req.amount).sub(amount);
    }

    function unstakeOf(address stakeholder) public view returns (uint256) {
        return unstakes[stakeholder].amount;
    }

    function releaseTimestampOf(address stakeholder) public view returns (uint256) {
        if(unstakeOf(stakeholder) > 0) {
            return unstakes[stakeholder].timestamp;
        }
        return 0;
    }

    function releaseStake() public {
        Unstake memory req = unstakes[_msgSender()];
        // Check if stake is releasable yet
        require(req.amount > 0, "StakingLenda: No stake to release");
        require(req.timestamp < block.timestamp, "StakingLenda: Cooldown period is not over");

        // Return the stake to the sender
        _transfer(address(this), _msgSender(), req.amount);

        // Remove the stake request
        unstakes[_msgSender()] = Unstake(0, 0);
        totalUnstakes = totalUnstakes.sub(req.amount);
    }

    // ============== RATE ================== /

    function setAnnualMintTarget(uint256 _mintTarget) public onlyOwner distributesReward {
        annualMintTarget = _mintTarget;
    }

    // APY is represented in %, since Solidity cannot do fractional math
    // APY can only be whole numbers, so no 0.x% values
    function currentAPY() public view returns (uint256) {
        if(totalStakes > 0) {
            return annualMintTarget.mul(100).div(totalStakes);
        }
        return annualMintTarget;
    }

    // ============== Rewards ============ /

    function _computeReward(uint256 deposit, uint256 increment) internal pure returns (uint256) {
        return deposit.mul(increment).div(365 days).div(100);
    }

    function _deliverReward(address stakeholder) internal {
        uint256 increment = currentSnapshot.sub(snapshots[stakeholder]);
        uint256 reward = _computeReward(stakes[stakeholder], increment);
        rewards[stakeholder] = rewards[stakeholder].add(reward);
        snapshots[stakeholder] = currentSnapshot;
    }

    modifier distributesReward {
        if(totalStakes > 0) {
            uint256 timeframe = block.timestamp.sub(lastDistribution);
            // Calculate the increment for the timeframe in annual percentage
            uint256 increment = currentAPY().mul(timeframe);
            currentSnapshot = currentSnapshot.add(increment);
        }
        lastDistribution = block.timestamp;
        _deliverReward(_msgSender());
        _;
    }

    function rewardOf(address stakeholder) public view returns (uint256) {
        // Calculate all undelivered rewards
        uint256 increment = currentSnapshot.sub(snapshots[stakeholder]);
        // Add all undistributed rewards
        uint256 timeframe = block.timestamp.sub(lastDistribution);
        increment = increment.add(currentAPY().mul(timeframe));
        // Convert the increments into reward
        uint256 reward = _computeReward(stakes[stakeholder], increment);
        return rewards[stakeholder].add(reward);
    }

    function withdrawReward() public distributesReward {
        uint256 reward = rewards[_msgSender()];
        require(reward > 0, "StakingLenda: You have no accumulated reward");
        rewards[_msgSender()] = 0;

        _mint(_msgSender(), reward); // Fails on cap reached and loses reward
    }

    function stakeReward() public distributesReward {
        uint256 reward = rewards[_msgSender()];
        require(reward > 0, "StakingLenda: You have no accumulated reward");
        rewards[_msgSender()] = 0;

        // Add stake
        _mint(address(this), reward); // Fails on cap reached and loses reward
        stakes[_msgSender()] = stakes[_msgSender()].add(reward);
        totalStakes = totalStakes.add(reward);
    }
}
