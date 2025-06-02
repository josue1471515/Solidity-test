// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./ERC20Basic.sol";

contract PlayLand
{
    //-------------------------------- token management --------------------------------
    ERC20Basic public gameToken;
    address payable public owner;
    constructor()
    {
        gameToken = new ERC20Basic(100000);
        owner = payable(msg.sender) ;
    }

    struct client
    {
        uint tokes_purchased;
        string[] AttractionsEnjoyed;
    }
    mapping (address =>client) public client_data;

    function tokensPrice(uint _numTokens) internal  pure returns (uint)
    {
        return  _numTokens*(1 ether);
    }

    function purchaseToken(uint _numTokens) external payable   
    {
        uint tokenCost  =  tokensPrice(_numTokens);

        require(msg.value >= tokenCost, "Insufficient Funds");
        uint returnValue = msg.value - tokenCost;
        payable(msg.sender).transfer(returnValue);
        uint Balance = balanceOf();
        require( _numTokens <=Balance, "Not Enough Tokens");
        gameToken.transfer(msg.sender, _numTokens);
        client_data[msg.sender].tokes_purchased += _numTokens;
    }

    function balanceOf() public view returns (uint)
    {
        return gameToken.balanceOf(address(this));
    }

    function MyTokens() public view returns(uint)
    {
       return gameToken.balanceOf(msg.sender);
    }

    function GenerateTokens(uint _numTokens) public OnlyOwner(msg.sender)
    {
        gameToken.increaseTotalSupply(_numTokens);
    }

    modifier OnlyOwner(address _direction)
    {
        require(_direction == owner,"Only Owner");
        _;
    }

    //-------------------------------- playland management --------------------------------

    //-- events
    event event_enjoyAttraction(string, uint);
    event event_newAttraction(string, uint);
    event event_disableAttraction(string);

    //----------------------------------- Attractions ------------------------------- //
    mapping (string => attraction) public MappingAttractions;       
         
    struct attraction 
    {
        string name_attraction;
        uint price_attraction;
        bool state_attraction;
    }

    string[] Attractions; 

    mapping (address => string[]) HistoryAttractions;

    function AddAttraction(string memory _nameAttraction, uint price)  public OnlyOwner(msg.sender)
    {
        MappingAttractions[_nameAttraction] = attraction(_nameAttraction , price, true);  
        Attractions.push(_nameAttraction);
        emit event_newAttraction(_nameAttraction, price);
    }

    function DisableAttraction(string memory _nameAttraction) public OnlyOwner(msg.sender)
    {
        MappingAttractions[_nameAttraction].state_attraction = false;
        emit event_disableAttraction(_nameAttraction);
    }

    function EnableAttractions() public view returns(string [] memory) 
    {
        return Attractions;
    }

    function EnjoyAttraction(string memory _nameAtraction) public 
    {
        uint tokes_attraction = MappingAttractions[_nameAtraction].price_attraction ;
        require( MappingAttractions[_nameAtraction].state_attraction == true,
            "Attractio not enabled");
            require(tokes_attraction <= MyTokens(),"You do not have enough tokens");
        
        gameToken.transfer_customer(msg.sender,address(this), tokes_attraction);
        HistoryAttractions[msg.sender].push(_nameAtraction);
        emit event_enjoyAttraction(_nameAtraction, tokes_attraction);
    }

    function Historical() public  view returns (string [] memory)
    {
        return HistoryAttractions[msg.sender];
    }

    function RevertTokens(uint _numTokens) public payable 
    {
        require(_numTokens > 0, "Invalid number of Tokens");
        require (_numTokens <= MyTokens(),"Not Enough Tokens");
        gameToken.transfer_customer(msg.sender, address(this), _numTokens);
        payable(msg.sender).transfer(_numTokens);
    }
} 