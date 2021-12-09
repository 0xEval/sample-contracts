import pytest
import brownie
from brownie import Crowdfunding, accounts
from brownie.test import given, strategy


@pytest.fixture(scope="session")
def alice(accounts):
    yield accounts[0]


@pytest.fixture(scope="session")
def bob(accounts):
    yield accounts[1]


@pytest.fixture(scope="session")
def charlie(accounts):
    yield accounts[1]


@pytest.fixture(scope="session")
# A fixture is called prior to execution of each test
def crowdfunding(alice):
    return brownie.Crowdfunding.deploy("100", "10", {"from": alice})


def test_is_owner(crowdfunding, alice):
    assert crowdfunding.admin() == alice


def test_crowdfunding_goal(crowdfunding):
    assert crowdfunding.goal() == 100


def test_contribute(crowdfunding, bob):
    old_amount = crowdfunding.raisedAmount()
    amt = "100"

    crowdfunding.contribute({"from": bob, "value": amt})
    assert crowdfunding.contributors(bob) == amt
    assert crowdfunding.noOfContributors() == 1
    assert crowdfunding.raisedAmount() == old_amount + amt


def test_contribute_fail_deadline(crowdfunding, bob):
    brownie.chain.sleep(crowdfunding.deadline() + 10000)
    brownie.chain.mine(100)
    with pytest.raises(brownie.exceptions.VirtualMachineError):
        crowdfunding.contribute({"from": bob, "value": "1 ether"})


def test_refund_isnt_contributor(crowdfunding, charlie):
    with brownie.reverts():
        crowdfunding.contribute({"from": charlie, "value": "1 ether"})


def test_refund_deadline(Crowdfunding, alice, bob):
    goal = "10 ether"
    deadline = "100"
    crowdfunding = brownie.Crowdfunding.deploy(goal, deadline, {"from": alice})
    crowdfunding.contribute({"from": bob, "value": "1 ether"})
    with brownie.reverts():
        crowdfunding.refund({"from": bob})

    brownie.chain.sleep(crowdfunding.deadline() + 10000)
    brownie.chain.mine(100)
    crowdfunding.refund({"from": bob})
    assert crowdfunding.contributors(bob) == 0


# Sample test using brownie accounts functions
def test_account_balance(alice, bob):
    orig_balance = alice.balance()
    alice.transfer(bob, "1 ether", gas_price=0)
    assert orig_balance - "1 ether" == alice.balance()


# This wrapping is a workaround for the following issue:
# https://github.com/eth-brownie/brownie/issues/918
def test_contribute_adjusts_raisedamount(accounts):
    brownie.chain.reset()
    crowdfunding = brownie.Crowdfunding.deploy("100", "100", {"from": accounts[0]})

    @given(
        sender=strategy("address", exclude=accounts[0]),
        value=strategy("uint256", min_value=100, max_value=10000),
    )
    def run(accounts, crowdfunding, sender, value):
        crowdfunding.contribute({"from": sender, "value": value})
        assert crowdfunding.contributors(sender) == value
        assert crowdfunding.raisedAmount() == value

    run(accounts, crowdfunding)
