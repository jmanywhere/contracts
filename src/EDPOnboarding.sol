// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract EDPOnboarding {
    struct User {
        bool isApproved;
        bool hasClaimed;
    }

    address public owner;
    mapping(address => User) public users;
    uint256 public totalUsersAdded; // New counter for total users

    uint256 public distributionAmount;
    bool public distributionSet;

    event UserApproved(address indexed user);
    event UserClaimed(address indexed user);

    error EDP__OnlyOwnerCanCall();
    error EDP__UserAlreadyApproved();
    error EDP__UserNotApproved();
    error EDP__UserAlreadyClaimed();
    error EDP__DistributionAlreadySet();
    error EDP__InsufficientFunds();
    error EDP__ZeroDistributionAmount(); // New error
    error EDP__TransferFailed();
    error EDP__NoBalanceToWithdraw(); // New error for withdraw function

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert EDP__OnlyOwnerCanCall();
        }
        _;
    }

    function approveUser(address _user) public onlyOwner {
        User memory user = users[_user];
        if (user.isApproved) {
            revert EDP__UserAlreadyApproved();
        }
        users[_user].isApproved = true;
        totalUsersAdded++;
        emit UserApproved(_user);
    }

    function setDistribution(uint256 _distAmount) public onlyOwner {
        if (distributionSet) {
            revert EDP__DistributionAlreadySet();
        }
        if (_distAmount == 0) {
            revert EDP__InsufficientFunds();
        }

        distributionAmount = _distAmount;

        if (distributionAmount == 0) {
            revert EDP__ZeroDistributionAmount();
        }

        distributionSet = true;
    }

    function claim() public {
        User memory user = users[msg.sender];
        if (!user.isApproved) {
            revert EDP__UserNotApproved();
        }
        if (user.hasClaimed) {
            revert EDP__UserAlreadyClaimed();
        }
        users[msg.sender].hasClaimed = true;
        emit UserClaimed(msg.sender);

        (bool success, ) = payable(msg.sender).call{value: distributionAmount}(
            ""
        );
        if (!success) {
            revert EDP__TransferFailed();
        }
    }

    function getUserStatus(
        address _user
    ) public view returns (bool isApproved, bool hasClaimed) {
        User memory user = users[_user];
        return (user.isApproved, user.hasClaimed);
    }

    // New function to withdraw all ETH balance
    function withdrawAllBalance() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) {
            revert EDP__NoBalanceToWithdraw();
        }

        (bool success, ) = payable(owner).call{value: balance}("");
        if (!success) {
            revert EDP__TransferFailed();
        }
    }
}
