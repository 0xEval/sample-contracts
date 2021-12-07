//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auction.sol";

/** @notice Stores & deploys Auction smart contracts.
 * Users calling the `createAuction()` gunction will be owners of deployed Auction.
 */
contract AuctionFactory {

    Auction[] public auctions;

    event AuctionDeployed(address);
    
    function createAuction() public {
        Auction a = new Auction(msg.sender);
        auctions.push(a);
        emit AuctionDeployed(address(a));
    }

}
