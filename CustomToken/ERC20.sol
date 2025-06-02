// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;
import "./../Libs/SafeMath.sol";

//Josue   =========> 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// fernando =========> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Claudia =========> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
interface IERC20
{
     function totalSupply () external  view returns (uint256);
     function balanceOf(address account) external  view returns (uint256);
     function allowance(address ownerm, address spender) external  view returns (uint256);
     function transfer(address recipient, uint256 amount) external  returns (bool);
     function approve(address spender, uint256 amount) external   returns (bool);
     function transferFrom(address sender, address recipient, uint256 amount ) external  returns (bool);
     //events
    event transferEvent(address indexed from, address indexed to,uint256  value);
    event approvalEvent(address indexed sender, address indexed spender,uint256 value);
}

contract ERC20 is IERC20
{
    string public  constant  name = "ERC20JosueChain";
    string public constant symbol = "ETHJC";
    uint8 public constant decimals = 2;
    using  SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping   (address=>uint)) allowed;
    uint256 totalSupply_;
    constructor(uint256 initialSupply)
    {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply () external override  view returns (uint256)
    {
        return totalSupply_;
    }
    
    function  increaseTotalSupply(uint newTokensAmount) public 
    {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) external override  view returns (uint256)
    {
        return balances[tokenOwner];
    }

    function allowance(address owner, address delegate) external override  view returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens) external override  returns (bool)
    {
        require(numTokens <= balances[msg.sender],"insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit transferEvent(msg.sender, recipient ,numTokens);
        return true;
    }
    
    function approve(address delegate, uint256 numTokens) external  override  returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit approvalEvent(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens ) external override  returns (bool)
    {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit transferEvent(owner, buyer , numTokens) ;
        return true;
    }
}