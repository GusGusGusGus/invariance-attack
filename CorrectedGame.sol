//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title This is the CORRECTED version of VulnerableGame.sol.
/// @dev adds invaricance checking a variable to keep track of the contract balance instead of changing its value directly, as it could be incremented initially in 2 ways: 1) selfdestruct contracts pointing to this contract's address would send this their balance without calling any function OR 2) contract addresses are deterministic, so a target address could be privately used (wrapped in a SHA3 hash function with the nonce and the target address) to create this contract's address before it is deployed and pre-load it with ether. 1) or 2) would thus increment the balance without the contract creators awareness, changing the execution logic.
contract CorrectedGame {
    uint256 public payoutMileStone1 = 3 ether;
    uint256 public mileStone1Reward = 2 ether;
    uint256 public payoutMileStone2 = 5 ether;
    uint256 public mileStone2Reward = 3 ether;
    uint256 public finalMileStone = 10 ether;
    uint256 public finalReward = 5 ether;
    uint256 public depositedWei;
    mapping(address => uint256) redeemableEther;

    // Users pay 0.5 ether. At specific milestones, credit their accounts.
    function play() public payable {
        require(msg.value == 0.5 ether); // each play is 0.5 ether
        uint256 currentBalance = depositedWei + msg.value;
        // ensure no players after the game has finished
        require(currentBalance <= finalMileStone);
        // if at a milestone, credit the player's account
        if (currentBalance == payoutMileStone1) {
            redeemableEther[msg.sender] += mileStone1Reward;
        } else if (currentBalance == payoutMileStone2) {
            redeemableEther[msg.sender] += mileStone2Reward;
        } else if (currentBalance == finalMileStone) {
            redeemableEther[msg.sender] += finalReward;
        }
        return;
    }

    function claimReward() public {
        // ensure the game is complete
        require(address(this).balance == finalMileStone);
        // ensure there is a reward to give
        require(redeemableEther[msg.sender] > 0);
        uint256 transferValue = redeemableEther[msg.sender];
        redeemableEther[msg.sender] = 0;
        payable(msg.sender).transfer(transferValue);
    }
}
