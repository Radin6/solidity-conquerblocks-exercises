// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;

contract Contract {
    struct Datos {
        address owner;
        address item;
    }

    Datos public datos;
    constructor(address _owner, address _item) {
        datos.owner = _owner;
        datos.item = _item;
    }
}

contract Factory {
    mapping (address owner_ => address contract_) user_contract;

    function creatContract() public  {
        address contract_ = address (new Contract(msg.sender, address(this)));
        user_contract[msg.sender] = contract_;
    }
    
}