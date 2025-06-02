// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;
import "./ERC20V2Basic.sol";

contract Lottery  
{
    ERC20V2Basic private  token;

    address public owner;
    address public  contract_created;

    uint tokens_created = 10000;

    constructor() {
       token = new ERC20V2Basic(tokens_created);
       owner = msg.sender;
       contract_created = address(this);
    }
    //Events 
     event BuyTokensEvent(uint, address);
    //
    function TokenPrice(uint _numTokens) public  pure  returns (uint) { return (_numTokens * (1 ether));}

    function GenerateToken(uint _numTokens) public OnlyOwner(msg.sender)
    {
        token.increaseTotalSupply(_numTokens);
    }

   function BuyTokens(uint _numTokens) public payable {
        uint priceTokens = TokenPrice(_numTokens);

        require(msg.value >= priceTokens, "Not enough ether");

        uint returnValue = msg.value - priceTokens;

        // Devolver el cambio si el usuario envió más ether del necesario
        if (returnValue > 0) {
            (bool success, ) = payable(msg.sender).call{value: returnValue}("");
            require(success, "Refund failed");
        }

    uint balance = AvailableTokens();
    require(_numTokens <= balance, "Not enough tokens available for sale");

    token.transfer(msg.sender, _numTokens);
    emit BuyTokensEvent(_numTokens, msg.sender);
}
    
    function ViewMyTokens() public view returns(uint)
    {
        return token.balanceOf(msg.sender);
    }

    function AvailableTokens() public view returns(uint)
    {
        return token.balanceOf(contract_created);
    }
    
    function AccumulatedWell() public view returns(uint){ return token.balanceOf(owner);}

    uint public TicketPrice  = 5;

    mapping (address => uint[]) idCustomer_Ticket;
    mapping (uint => address) idTicket_Customer ;
    uint randNonce = 0;
    uint[] tickets_purchased;

    event TicketPurchased(uint);
    event TicketWinner(uint);

    function BuyTickets(uint _tickets) public 
    {
        uint total_price = _tickets * TicketPrice;
        require(total_price <= ViewMyTokens(),"Not enough tokens available for sale");

        token.transfer_customer(msg.sender, owner, total_price);

        for(uint i = 0 ; i < _tickets;i++)
        {
            uint random = uint(keccak256(abi.encodePacked( block.timestamp, msg.sender, randNonce))) % tokens_created;
            randNonce++;

            idCustomer_Ticket[msg.sender].push(random);

            tickets_purchased.push(random);

            idTicket_Customer[random] = msg.sender;
            emit  TicketPurchased(random);
        }
    }

    function MyTickets() public  view returns(uint[] memory){return idCustomer_Ticket[msg.sender];}

    function GenerateWinner() public OnlyOwner(msg.sender)
    {
        require(tickets_purchased.length > 0,"No tickets purchased yet!" );
        uint long = tickets_purchased.length;
        uint position_array = uint(keccak256(abi.encodePacked(block.timestamp))) % long ;
        uint select = tickets_purchased[position_array];

        emit TicketWinner(select);

        address winner = idTicket_Customer[select];
        token.transfer_customer(msg.sender, winner, AccumulatedWell());
    }
    
    function ReturnTokens(uint _numTokens) public payable 
    {
        require(_numTokens > 0,"Must be at least 1 token for this transaction!");
        require(_numTokens <= ViewMyTokens(), "Not enough tokens available for sale");
        token.transfer_customer(msg.sender, address(this), _numTokens);
        payable(msg.sender).call{value: TokenPrice(_numTokens)};

    }

    modifier OnlyOwner (address _owner) 
    {
        require(_owner == owner,"You are not authorized to do this");
        _;
    }


}