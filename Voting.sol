// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Voting Contract
/// @notice A simple voting system where owner can add members and users can vote once
contract Voting{

    struct Member{
        address member;
        uint128 memberVotes;
    }

    uint public totalVotes;
    address public owner;
    uint128 public startTime;
    uint128 public endingTime;
    bool isVotingStarted;
    bool isPaused;

    mapping(address=>Member) public memberVotes;
    mapping(address=>bool) public isVoted;
    mapping(address=>bool) isMember;

    event MemberAdded(address indexed member,uint128 timeAdded);
    event UserVoted(address indexed user, address indexed member, uint128 timeVoted);
    event votingPaused(uint128 time);
    event votingResumed(uint128 time);

    /// @notice Initializes the contract and sets deployer as owner and first member
    constructor(){
        owner = msg.sender;
        isMember[owner] = true;
        memberVotes[owner] = Member(owner,0);
    }

    /// @notice Ensures contract is not paused
    modifier whenNotPaused{
        require(!isPaused,"Contract Is Paused");
        _;
    }

    /// @notice Restricts function access to contract owner
    modifier onlyOwner(){
        require(msg.sender==owner,"Not Authorised");
        _;
    }

    /// @notice Pauses the voting contract
    /// @dev Only callable by owner
    function pauseContract() public onlyOwner{
        require(!isPaused,"Already Paused");
        isPaused = true;
        emit votingPaused(uint128(block.timestamp));
    }

    /// @notice Resumes the voting contract
    /// @dev Only callable by owner
    function resumeContract() public onlyOwner{
        require(isPaused,"Not Paused");
        isPaused = false;
        emit votingResumed(uint128(block.timestamp));
    }

    /// @notice Starts the voting process
    /// @dev Sets start and end time based on duration
    /// @param _endTime Duration of voting in days
    function startVoting(uint _endTime) public {
        require(msg.sender==owner,"Not Authorised");
        require(!isVotingStarted,"Voting Already Started. Wait For It To Stop");

        startTime = uint128(block.timestamp);
        endingTime = uint128(block.timestamp + (_endTime*1 days));
        isVotingStarted = true;
    }

    /// @notice Stops the voting process after end time
    /// @dev Only callable by owner and after voting period ends
    function stopVoting() public {
        require(msg.sender==owner,"Not Authorised");
        require(isVotingStarted,"Not Started");
        require(block.timestamp>endingTime,"Voting Is Not Ended");

        isVotingStarted = false;
    }

    /// @notice Adds a new member eligible for voting
    /// @dev Only owner can add members
    /// @param _user Address of the member to be added
    function makeMember(address _user) public{
        require(msg.sender==owner,"Not Authorised");
        require(!isMember[_user],"Already A Member");

        isMember[_user] = true;
        memberVotes[_user] = Member(_user,0);

        emit MemberAdded(_user, uint128(block.timestamp));
    }

    /// @notice Allows a user to vote for a member
    /// @dev Each address can vote only once and only during active voting period
    /// @param _member Address of the member being voted for
    function vote(address _member) public whenNotPaused{
        require(isVotingStarted, "Voting not started");
        require(block.timestamp <= endingTime, "Voting ended");
        require(isMember[_member],"User Is Not A Member");
        require(!isVoted[msg.sender],"Already Voted");

        Member storage m = memberVotes[_member];

        totalVotes++;
        m.memberVotes++;
        isVoted[msg.sender] = true;

        emit UserVoted(msg.sender, _member, uint128(block.timestamp));
    }

    /// @notice Returns the winning member (not implemented yet)
    /// @dev Should iterate through members and find highest votes
    /// @return winner The member with highest votes
    function getWinner() public view returns(Member memory){
        // Not implemented
    }

    /// @notice Returns vote details of a specific member
    /// @param _user Address of the member
    /// @return Member struct containing address and vote count
    function viewVotes(address _user) public view returns(Member memory){
        return memberVotes[_user];
    }
}
