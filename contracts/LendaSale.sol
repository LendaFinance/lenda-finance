// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

/**
 * @title LendaSale
 * @dev This is an example of a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundablePostDeliveryCrowdsale - set a min goal to be reached and returns funds if it's not met
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract LendaSale is CappedCrowdsale, RefundablePostDeliveryCrowdsale {
    constructor (
        ERC20Burnable token,
        address payable wallet,
        uint256 rate,
        uint256 goal,
        uint256 cap,
        uint256 openingTime,
        uint256 closingTime
    )
        public
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(cap)
        TimedCrowdsale(openingTime, closingTime)
        RefundableCrowdsale(goal)
    {
        require(goal <= cap, "SampleCrowdSale: goal is greater than cap");
    }

    function isOpen() public view returns (bool) {
        return super.isOpen() && !super.capReached();
    }

    function hasClosed() public view returns (bool) {
        return super.hasClosed() || super.capReached();
    }

    function _finalization() internal {
        super._finalization();
        ERC20Burnable token = ERC20Burnable(address(super.token()));
        uint256 remaining = token.balanceOf(address(this));
        if(remaining > 0) {
            token.burn(remaining);
        }
    }
}
