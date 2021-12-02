// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Lottery {
    address private manager;
    address payable[] public players;

    modifier isManager() {
        require(msg.sender == manager);
        _;
    }

    event playerEntered(address _player);
    event fundsTransfered(address _to);
    event lotteryReset();

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.1 ether, "Lottery: incorrect payment amount");
        players.push(payable(msg.sender));
        emit playerEntered(msg.sender);
    }

    function getBalance() public view isManager returns (uint256) {
        return address(this).balance;
    }

    function pickWinner() public isManager {
        require(players.length >= 3);
        uint256 index = random() % players.length;
        transferFunds(payable(players[index]));
        resetLottery();
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
