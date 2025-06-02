// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;


contract vote
{
    address public  owner;
    constructor ()
    {
        owner=msg.sender;
    }
    
    mapping (string=>bytes32) ID_candidate;
    mapping (string => uint8 ) votes_canditate;
    string[] candidates;
    bytes32[] voters;
    
    function Represent(string memory _namePerson, uint _agePerson,string memory _idPerson)   public 
    {
        bytes32 hash_candidate = keccak256(abi.encodePacked(_namePerson,_agePerson,_idPerson ));
        ID_candidate[_namePerson] = hash_candidate;
        candidates.push(_namePerson);
    }

    function ViewCanditates() public view  returns (string[] memory)
    {
        return  candidates;
    }

    function VoteCandidate(string memory _nameCandidate) public  
    {
        bytes32 hash_voter = keccak256(abi.encodePacked(msg.sender));
        for (uint i = 0 ; i <voters.length; i++)
        {
            require(voters[i] != hash_voter, "Vote already exist");            
        }
        voters.push(hash_voter);
        votes_canditate[_nameCandidate]++;
    }

    function viewResultCandidate(string memory _nameCandidate) public view   returns (uint8)
    {
        return votes_canditate[_nameCandidate];
    }

     function ViewResults() public view returns(string memory){
        //Guardamos en una variable string los candidatos con sus respectivos votos
        string memory resultados="";
        
        //Recorremos el array de candidatos para actualizar el string resultados
        for(uint i=0; i<candidates.length; i++){
            resultados = string(abi.encodePacked(resultados, "(", candidates[i], ", ", uint2str(viewResultCandidate(candidates[i])), ") -----"));
        }
        return resultados;
    }

    function Winner() public view returns(string memory){
        
        //La variable ganador contendra el nombre del candidato ganador 
        string memory winner= candidates[0];
        bool flag;
        
        //Recorremos el array de candidatos para determinar el candidato con un numero de votos mayor
        for(uint i=1; i<candidates.length; i++){
            if(votes_canditate[winner] < votes_canditate[candidates[i]]){
                winner = candidates[i];
                flag=false;
            }else{
                if(votes_canditate[winner] == votes_canditate[candidates[i]]){
                    flag=true;
                }
            }
        }
        
        if(flag==true){
            winner = "There is a tie between the candidates!";
        }
        return winner;
    }

       function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes  memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}