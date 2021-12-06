//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/** @notice Simple decentralized Auction contract similar to eBay.
 *
 * Requirements:
 *
 * - Auction has an `owner` (the person who sells a good or service), a `start` and an `end` date.
 * - `owner` can cancel the auction if there is an emergency or can finalize the auction after its
 * end time.
 * - People can send ETH using the `placeBid()` function. The sender's address and the value sent
 * will be stored in a mapping called bids.
 * - Users are incentivized to bid the maximum they are willing to pay, but they are not bound to
 * that full amount, but rather to the previous highest bid plus an `increment`. The contract is
 * *responsible* to bid up to a given amount.
 * - The `highestBindingBid` is the selling price and the `highestBidder` the person of who won the
 * auction.
 * - After the auction ends, the owner gets the `highestBindingBid` and everybody else `withdraws`
 * their own amount.
 */
contract Auction {

    address payable public owner;

    // Solidity does not have native date types. Instead, dates are represented as integers using
    // timestamps in seconds.
    uint256 public startBlock;
    uint256 public endBlock;

    // Stores the IFS hash corresponding to the offchain description/information about the sale
    string public ipfsHash;

    State public auctionState;

    uint256 public highestBindingBid;
    address payable public highestBidder;

    uint256 private bidIncrement;
    mapping(address => uint) bids;

    enum State {
        Started,
        Running,
        Ended,
        Canceled
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _; // <- the calling function body is inserted there
    }

    modifier notOwner {
        require(msg.sender != owner);
        _; // <- the calling function body is inserted there
    }

    modifier isRunning {
        require(auctionState == State.Running);
        _;
    }

    modifier beforeEnd {
        require(block.number < endBlock);
        _;
    }

    modifier afterStart {
        require(block.number > startBlock);
        _;
    }

    constructor(address eoa) {
        owner = payable(eoa);
        // It is insecure to rely on block.timestamp as it can be controlled by miners.
        // Ethereum block time is 15 seconds, therefore we can calculate the time
        // based on this information.
        // Example:
        // 1 week = 604,800 seconds / 15 = 40,320 blocks generated
        startBlock = block.number;
        endBlock = startBlock + 40320; // Human-readable time can be handled at the frontend level
        auctionState = State.Running;
        ipfsHash = "";
        bidIncrement = 100;
    }

    receive() external payable {

    }

    function cancel() public onlyOwner {
        auctionState = State.Canceled;
    }

    // The "withdrawal pattern" is a pattern that helps avoiding re-entrance attacks (e.g: TheDAO
    // hack).
    // In summary a contract should *only send ETH* to a user when he *explicitly* requests it.
    function finalizeAuction()  public {
        require(auctionState == State.Canceled || auctionState == State.Ended);
        require(msg.sender == owner || bids[msg.sender] > 0);

        address payable recipient;
        uint256 value;

        if (auctionState == State.Canceled) {
            recipient = payable(msg.sender); // Auction has been cancelled (refunds)
            value = bids[msg.sender];        // Every user needs to call this function to get his money back
        } else {
            if (msg.sender == owner) { // Auction has been ended by manager
                recipient = owner;
                value = highestBindingBid; // Contract receveives the highest binding bid
            } else {
                if (msg.sender == highestBidder) { // Auction has been ended by highest bidder
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid; // Winner receives his max bid minus binding bid
                } else {
                    recipient = payable(msg.sender); // Auction has been ended by another bidder
                    value = bids[msg.sender];
                }
            }
        }
		// Function can only be called once per user
		bids[recipient] = 0;
        recipient.transfer(value);
    }

    function min(uint a, uint b) pure internal returns(uint256) {
        if (a <= b) { return a; } else { return b; }
    }

    function placeBid() public payable notOwner isRunning afterStart beforeEnd {
        require(msg.value >= bidIncrement);

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);

        bids[msg.sender] = currentBid;

        if (currentBid <= bids[highestBidder]) {
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid,  bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }
}


