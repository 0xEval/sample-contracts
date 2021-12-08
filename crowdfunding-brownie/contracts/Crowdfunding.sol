// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/** @notice Decentralized version of Crowdfunding campaigns inspired by Kickstarter model.
 * Requirements:
 * - `Admin` starts a campaign with a specific monetary `goal` and `deadline`.
 * - `Contributors` will contribute to that project by sending ETH.
 * - The admin has to create a _Spending Request_ to spend money for the campaign.
 * - Once the spending request was created, the contributors can start `voting` for that specific request.
 * - If more than 50% of the total contributors voted for that request, then the admin would have the permission to spend the amount specified in the spending request
 * - The power is moved from the campaign's admin to those that donated money.
 * - The contributors can request a `refund` if the monetary goal was not reached within the deadline.
 */
contract Crowdfunding {
    address public admin;

    uint256 public minimumContribution;
    uint256 public raisedAmount;
    uint256 public goal;
    uint256 public deadline; //timestamp

    uint256 public noOfContributors;
    mapping(address => uint256) public contributors;

    uint256 public numRequests;
    mapping(uint256 => Request) public requests;

    struct Request {
        string description;
        address payable recipient;
        uint256 value;
        bool completed;
        uint256 noOfVoters;
        mapping(address => bool) voters;
    }

    constructor(uint256 _goal, uint256 _deadline) {
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }

    receive() external payable {
        contribute();
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Error: deadline has passed");
        require(
            msg.value >= minimumContribution,
            "Error: minimum contribution not met"
        );

        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /** @notice Contributors can be refunded if `goal` was not reached within the expected
     * ` deadline`.
     */
    function refund() public {
        require(block.timestamp > deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);

        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Crowdfunding: only admin can call this function!"
        );
        _;
    }

    function createRequest(
        string memory _description,
        address payable _recipient,
        uint256 _value
    ) public onlyAdmin {
        Request storage newRequest = requests[numRequests];
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function voteRequest(uint256 _requestNo) public {
        require(
            contributors[msg.sender] > 0,
            "Crowdfunding: must be a contributor!"
        );
        require(
            requests[_requestNo].voters[msg.sender] == false,
            "Crowdfunding: cannot vote twice!"
        );
        Request storage req = requests[_requestNo];
        req.voters[msg.sender] = true;
        req.noOfVoters++;
    }

    function makePayment(uint256 _requestNo) public onlyAdmin {
        require(
            requests[_requestNo].noOfVoters >= noOfContributors / 2,
            "Crowdfunding: insufficient voters"
        ); // 50% voted for this request (naive approach ofc)
        require(raisedAmount >= goal, "Crowdfunding: goal not reached!");
        require(
            requests[_requestNo].completed == false,
            "Crowdfunding: request already completed"
        );
        Request storage req = requests[_requestNo];
        req.recipient.transfer(req.value);
        req.completed = true;
    }
}
