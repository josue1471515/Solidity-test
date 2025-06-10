// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.9 <0.9.0;
pragma experimental ABIEncoderV2;

contract oms 
{
    address public OMS;

    constructor()   
    {
        OMS = msg.sender;
    }
    // OMS : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // CENTRO 1 : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // CENTRO 2 : 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    mapping (address => bool) Validation_HealthCenter;

    address[] public health_contract_addresses;
    address[] Requests;

    event NewContract(address creater,address owner);
    event NewContractValidated(address);
    event RequestedAccess(address);

    modifier OnlyOMS(address _address) {
        require (_address == OMS,"Only OMS");
        _; 
    }

    function CreateHealthCenter(address _heathCenter) public OnlyOMS(msg.sender)
    {
        Validation_HealthCenter[_heathCenter] = true;
        emit NewContractValidated(_heathCenter);
    }

    function FactoryHealthCenter() public 
    {
        require(Validation_HealthCenter[msg.sender] == true,"Dont have access");
        address contract_HealthCenter= address(new HealthCenter(msg.sender));

        health_contract_addresses.push(contract_HealthCenter);
        emit NewContract(contract_HealthCenter,msg.sender);
    }
    
    function ViewRequest() public view OnlyOMS(msg.sender) returns(address[] memory)
    {
        return Requests;
    }
    
    function RequestAccess() public 
    {
        Requests.push(msg.sender);
        emit RequestedAccess(msg.sender);
    }
}

contract HealthCenter
{
    address public  ContractDirection;
    address public  ContractHealthCenter;

    constructor (address _address )  
    {
        ContractHealthCenter = _address;
        ContractDirection = address(this);
    }
}