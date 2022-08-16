// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract MultiSignatureWallet {
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed transactionId);
    event Approve(address indexed owner, uint indexed transactionId);
    event Revoke(address indexed owner, uint indexed transactionId);
    event Execute(uint indexed transactionId);

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public requiredSigners;

    Transaction[] public transactions;
    // approved transaction by a signer
    mapping(uint => mapping(address => bool)) public approvedByOwner;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required number of owners");

        for(uint i; i < owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        
        requiredSigners = _required;
    }

    receive() external payable {
            emit Deposit(msg.sender, msg.value);
    }

    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data:_data,
            executed: false
        }));
    }
}
