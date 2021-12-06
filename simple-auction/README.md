# Simple Decentralized Auction

This contract replicates a simple decentralized version of an eBay auction. Any user can create his own Auction by calling the `createAuction()` function from the `AuctionFactory` contract.

# Requirements

- An **Auction** has an `owner` (the person who sells a good or service), a `start` and an `end` date. 
- `owner` can cancel the auction if there is an emergency or can finalize the auction after its end time.
- People can send ETH using the `placeBid()` function. The sender's address and the value sent will be stored in a mapping called bids.
- Users are incentivized to bid the maximum they are willing to pay, but they are not bound to that full amount, but rather to the previous highest bid plus an `increment`. 
- The contract is *responsible* to bid up to a given amount.
- The `highestBindingBid` is the selling price and the `highestBidder` the person of who won the auction.
- After the auction ends, the owner gets the `highestBindingBid` and everybody else `withdraws` their own amount.
