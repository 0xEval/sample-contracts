# Simple Decentralized Auction

Decentralized version of Crowdfunding campaigns inspired by Kickstarter model.

# Requirements

 - `Admin` starts a campaign with a specific monetary `goal` and `deadline`.
 - `Contributors` will contribute to that project by sending ETH.
 - The admin has to create a _Spending Request_ to spend money for the campaign.
 - Once the spending request was created, the contributors can start `voting` for that specific request.
 - If more than 50% of the total contributors voted for that request, then the admin would have the permission to spend the amount specified in the spending request
 - The power is moved from the campaign's admin to those that donated money.
 - The contributors can request a `refund` if the monetary goal was not reached within the deadline.