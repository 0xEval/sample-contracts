// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Lottery {
    address private manager;
    address payable[] public players;
    uint256 public constant FEE = 10;

    modifier isManager() {
        require(msg.sender == manager);
        _;
    }

    event playerEntered(address _player);
    event fundsTransfered(address _to);
    event lotteryReset();

    constructor() {
        manager = msg.sender;
        players.push(payable(manager)); // Sneaky owner wants a part of it too (but he gets a free entry!)
    }

    receive() external payable {
        require(msg.value == 0.1 ether, "Lottery: incorrect payment amount");
        players.push(payable(msg.sender));
        emit playerEntered(msg.sender);
    }

    function getBalance() public view isManager returns (uint256) {
        return address(this).balance;
    }

    function pickWinner() public {
        require(players.length >= 10);
        uint256 index = random() % players.length;
        transferFees(); // Manager receives a 10% cut for each lottery round
        transferFunds(payable(players[index]));
        resetLottery();
    }

    function transferFees() private {
        uint256 managerFee = (getBalance() * FEE) / 100;
        payable(manager).transfer(managerFee);
        emit fundsTransfered(manager);
    }

    function transferFunds(address payable _to) private {
        _to.transfer(getBalance());
        emit fundsTransfered(_to);
    }

    function resetLottery() private isManager {
        delete players;
        emit lotteryReset();
    }

    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }
}
