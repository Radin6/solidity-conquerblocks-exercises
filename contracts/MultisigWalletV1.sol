// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract MultisigWallet {

    event executedTx(uint txId, address to, uint value);
    event confirmedTx(uint txId, address to, uint value);
    event submittedTx(uint txId, address to, uint value);

    address[] public owners;
    uint public minConfirm;
    mapping (address => bool) public isOwner;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirm;
    }

    Transaction [] public transactions;
    mapping (uint => mapping (address => bool)) public isConfirmed;

    modifier onlyOwner() {
        require(isOwner[msg.sender] == true, "You are not the owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(transactions.length > _txId, "Transaction does not exist");
        _;
    }

    modifier notConfirmed(uint _txId) {
        require(isConfirmed[_txId][msg.sender] == false, "Transaction already confirmed by you");
        _;
    }

    constructor(address[] memory _owners, uint _minConfirm) payable {
        require(0 < _minConfirm && _minConfirm <= _owners.length, "Wrong Confirmation number");
        require(_owners.length > 0, "You need at least 2 owners");
        owners = _owners;
        minConfirm = _minConfirm;

        for (uint i=0; i < owners.length; i++) {
            isOwner[owners[i]] = true;
        }
    }

    receive () external payable {}

    function submitTx(address _to, uint _value) public onlyOwner {
        transactions.push(Transaction(_to, _value, "", false, 0));

        emit submittedTx(transactions.length, _to, _value);
    }

    function confirmTx(uint _txId) public txExists(_txId) onlyOwner notConfirmed(_txId){
        isConfirmed[_txId][msg.sender] = true;
        transactions[_txId].numConfirm +=1;

        emit confirmedTx(_txId, transactions[_txId].to, transactions[_txId].value);

        if (transactions[_txId].numConfirm >= minConfirm) {executeTx(_txId);}
    }

    function executeTx(uint _txId) internal {

        (bool success, ) = transactions[_txId].to.call {value: transactions[_txId].value}(
            transactions[_txId].data
        ); 

        require(success, "Transaction failed");
        transactions[_txId].executed = true;

        emit executedTx(_txId, transactions[_txId].to, transactions[_txId].value);
    }

    function getOwners() public view returns(address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns(uint) {
        return transactions.length;
    }

    function getTransaction(uint _txId) public view returns(
        address to,
        uint value,
        bytes memory _data,
        bool _executed,
        uint _numConfirm) 
    {
        Transaction storage transaction = transactions[_txId];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirm
        );
    }

}

