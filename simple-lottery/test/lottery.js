const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const Lottery = artifacts.require("Lottery");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Lottery", function (accounts) {
  it("should assert true", async function () {
    await Lottery.deployed();
    return assert.isTrue(true);
  });

  it("reverts when received incorrect amount", async function () {
    let contract = await Lottery.deployed();

    await expectRevert(
      web3.eth.sendTransaction({
        from: accounts[0],
        to: contract.address,
        value: web3.utils.toWei('1', 'ether')
      }),
      "Lottery: incorrect payment amount"
    );
  });

  it("should reset after winner is picked", async function () {
    let contract = await Lottery.deployed();
    return assert.isTrue(contract.players.length == 0);
  });
});
