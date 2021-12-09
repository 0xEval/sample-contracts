import pytest
import brownie


@pytest.fixture(scope="session")
def alice(accounts):
    yield accounts[0]


@pytest.fixture(scope="session")
def bob(accounts):
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
    # Account 1 contributes to crowdfund
    old_amount = crowdfunding.raisedAmount()
    amt = "100"
    # Fast-forward the clock past the deadline

    crowdfunding.contribute({"from": bob, "value": amt})
    assert crowdfunding.contributors(bob) == amt
    assert crowdfunding.noOfContributors() == 1
    assert crowdfunding.raisedAmount() == old_amount + amt


def test_contribute_fail_deadline(crowdfunding, bob):
    brownie.chain.sleep(crowdfunding.deadline() - 100)
    brownie.chain.mine(100)
    with pytest.raises(brownie.exceptions.VirtualMachineError):
        crowdfunding.contribute({"from": bob, "value": "1 ether"})


# Sample test using brownie accounts functions
def test_account_balance(alice, bob):
    orig_balance = alice.balance()
    alice.transfer(bob, "1 ether", gas_price=0)
    assert orig_balance - "1 ether" == alice.balance()
