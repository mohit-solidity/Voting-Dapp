// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Pool{
    function check(string calldata _str) public pure returns(string memory){
        require(keccak256(abi.encodePacked(_str))==keccak256(abi.encodePacked("SPIDO")),"Not Same");
        return ("Perfect");
    }
    function pay() public payable returns(string memory){
        require(msg.value>0 ether,"Must Greater Than 0 ETH");
        return("Transaction Success");
    }
    function checkData() public pure returns(string memory){
        require(keccak256(abi.encodePacked()) == keccak256(abi.encodePacked()),"Not Matched");
        return("HELLO WORLD");
    }
    function checkBalance() public view returns(uint){
        return (address(this).balance);
    }
}