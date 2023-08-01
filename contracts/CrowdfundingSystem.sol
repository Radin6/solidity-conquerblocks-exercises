// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract CrowdfundingSystem {

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    uint public count;
    mapping (uint => Campaign) public campaigns;
    // campaign ID => pledger => amount pledged
    mapping (uint => mapping(address => uint)) public pledgedAmount;

    IERC20 public immutable token;

    event Launch (uint id, address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    event Cancel (uint id);
    event Pledge (uint id, address indexed pledger, uint amount);
    event Unpledge (uint id, address indexed pledger, uint amount);
    event Claimed (uint _id, uint pledged);
    event Refund (uint id, address indexed pledger, uint ammount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch (uint _goal, uint32 _startAt, uint32 _endAt) external {
        require (_startAt >= block.timestamp, "CrowdfundingSystem: Invalid start time");
        require (_endAt >= _startAt, "CrowdfundingSystem: End time must be > than start time");
        require (_endAt <= block.timestamp + 90 days, "CrowdfundingSystem: Invalid end time");

        count = count + 1;
        campaigns[count] = Campaign (msg.sender, _goal, 0, _startAt, _endAt, false);
        emit Launch ( count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel (uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "CrowdfundingSystem: You are not the creator");
        require(block.timestamp < campaign.startAt, "CrowdfundingSystem: The campaign has already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge (uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp >= campaign.startAt, "Crowdfunding System: The campaign hasn't started");
        require(block.timestamp <= campaign.endAt, "CrowdfundingSystem: The campaign has ended");

        token.transferFrom(msg.sender, address(this), _amount);
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge (uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "CrowdfundingSystem: The campaign has ended");
        uint pledged = pledgedAmount[_id][msg.sender];
        require(pledged >= _amount, "CrowdfundingSystem: not enough tokens pledged");

        pledgedAmount[_id][msg.sender] -= _amount;
        campaign.pledged -= _amount;

        token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);

        
    }

    function claim (uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "Crowdfunding System: You are not the creator");
        require(block.timestamp > campaign.endAt, "Crowdfunding System: The campaign hasn't ended");
        require(campaign.pledged >= campaign.goal, "Crowdfunding System: The goal hasn't been reached");
        require(!campaign.claimed, "Crowdfunding System: Claimed");

        campaign.claimed = true;

        token.transfer(campaign.creator, campaign.pledged);

        emit Claimed(_id, campaign.pledged);
    }

    // if goal hasn't been reached the pledgers can get their tokens refunded
    function refund (uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Crowdfunding System: The campaign hasn't ended");
        require(campaign.pledged < campaign.goal, "Crowdfunding System: The goal has been reached");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;

        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }

}
