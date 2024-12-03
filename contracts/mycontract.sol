// SPDX-License-Identifier: UNLICENSED

// DO NOT MODIFY BELOW THIS
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Splitwise {
// DO NOT MODIFY ABOVE THIS

// ADD YOUR CONTRACT CODE BELOW
    address public owner;
    address[] public people;
    mapping(address => bool) participant; // check có nợ không
    
    struct Ownership {
        address ownerAddress; // địa chỉ người cho vay
        uint256 amount; // tiền nợ
    }

    mapping(address => Ownership[]) owingData;

    constructor() {
        owner = msg.sender;
    }

    function setParticipant(address user) private {
        if (!participant[user]) {
            people.push(user);
            participant[user] = true;
        }

    }
    
    function getParticipant() public view returns (address[] memory) {
        return people;
    }
    

    function getAllOwingData(address user) public view returns (Ownership[] memory) {
        return owingData[user];
    }

function lookup(address debtor, address creditor) public view returns (uint256 ret) {
    Ownership[] memory data = owingData[debtor];
    for (uint256 i = 0; i < data.length; i++) {
        if (data[i].ownerAddress == creditor) {
            return data[i].amount;
        }
    }
}

function resolveLoopsDebt(address debtor, address creditor, uint256 amount) private {
    for(uint i = 0; i < owingData[creditor].length; i++) {
        if (owingData[creditor][i].ownerAddress == debtor) {
            if (owingData[creditor][i].amount > amount) {
                owingData[creditor][i].amount -= amount;
                return;
            }
            else if (owingData[creditor][i].amount < amount) {
                uint256 owingAmount = owingData[creditor][i].amount;
                delete owingData[creditor][i];
                amount -= owingAmount;
            }
            else {
                delete owingData[creditor][i];
                return;
            }
        }
    }
}


    function iou(address debtor, address creditor, uint256 amount) public {
        require(debtor != creditor);
        setParticipant(debtor);
        setParticipant(creditor);
        resolveLoopsDebt(debtor, creditor, amount);
        for (uint i = 0; i < owingData[debtor].length; i++) {
            if (owingData[debtor][i].ownerAddress == creditor) {
                owingData[debtor][i].amount += amount;
                return;
            }
        }
        Ownership memory newOwingData;
        newOwingData.ownerAddress = creditor;
        newOwingData.amount = amount;
        owingData[debtor].push(newOwingData);
    }

}
