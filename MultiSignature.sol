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

    modifier txExists(uint _txId){
        require(_txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notApproved(uint _txId){
        require(!approvedByOwner[_txId][msg.sender], "Transaction already approved");
        _;
    }
    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed, "Transaction already executed");
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
        emit Submit(transactions.length - 1);
    }

    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approvedByOwner[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function getApprovalCount(uint _txId) private view returns (uint count) {
        for (uint i; i < owners.length; i++){
            if (approvedByOwner[_txId][owners[i]]){
                count += 1;
            }
        }
    }

    function executed(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(getApprovalCount(_txId) >=  requiredSigners, "Approvals is less than required signers");
        Transaction storage  transaction = transactions[_txId];
        transaction.executed = true;

        (bool sucess,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(sucess, "transaction failed");

        emit Execute(_txId);
    }

    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        require(approvedByOwner[_txId][msg.sender], "Transaction not approved");
        approvedByOwner[_txId][msg.sender] = false;

        emit Revoke(msg.sender, _txId);
    }
}
