// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
pragma experimental ABIEncoderV2;

contract notes {
    address public  theacher;

    constructor() {
        theacher = msg.sender;
    }

    mapping (bytes32 => uint) Notes;

    string[] reviews;

    event student_evaluated(bytes32);
    event event_revision(string);

    function Evaluation(string memory _idStudent, uint _note) public TeacherOnly(msg.sender)
    {
        bytes32 hash_idStudent = keccak256(abi.encodePacked(_idStudent));
        Notes[hash_idStudent] = _note;
        emit student_evaluated(hash_idStudent);
    }

    modifier TeacherOnly(address _theacher) 
    {
        require(theacher == _theacher, "don't have permissions.");
        _;
    }

    function GetEvaluations(string memory _idStudent) public view returns(uint)
    {
        bytes32 hash_idStudent = keccak256(abi.encodePacked(_idStudent));
        return Notes[hash_idStudent];
    }
    
    function Revise(string memory _idStudent) public
    {
        reviews.push(_idStudent);
        emit event_revision(_idStudent);
    }

    function ViewReviews() public view TeacherOnly(msg.sender) returns(string[] memory)
    {
        return reviews;
    }
}
