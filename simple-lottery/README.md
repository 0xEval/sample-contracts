# Simple Decentralized Lottery

This contract is a simple concept of decentralized lottery. Players enter the game by purchasing a
fixed-price ticket. After enough players entered the game, a winner is picked and receives all the
collected ticket funds.

## Contract requirements

* Lottery is managed by an individual
* Price of a lottery ticket is **0.1 ETH**
* Minimum amount of players is 3
* Lottery will be reset after a winner is picked

## Deploy & Test

1. Enable development network in `truffle-config.js`
2. Start development network (using ganache-cli or ganache GUI for example)
3. Deploy contracts using: `truffle deploy`
4. Run test-suite using: `truffle test`
