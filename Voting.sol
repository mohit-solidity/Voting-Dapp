// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Voting Contract
/// @notice A simple voting system where owner can add members and users can vote once
contract Voting{

    struct Member{
        address member;
        uint128 memberVotes;
    }

    uint public latestVotingIndex = 0;
    address public owner;
    bool isVotingStarted;
    bool isPaused;

    mapping(uint=>uint128) public startTime;
    mapping(uint=>uint128) public endingTime;
    mapping(uint=>uint) public totalVotes;
    mapping(uint=>address) public currentWinner;
    mapping(uint=>address) public secondHighestVotes;
    mapping(uint=>address[]) public members;
    mapping(uint=>mapping(address=>Member)) public memberVotes;
    mapping(uint=>mapping(address=>bool)) public isVoted;
    mapping(uint=>mapping(address=>bool)) isMember;

    event MemberAdded(address indexed member,uint128 timeAdded);
    event UserVoted(address indexed user, address indexed member, uint128 timeVoted);
    event votingPaused(uint128 time);
    event votingResumed(uint128 time);

    /// @notice Initializes the contract and sets deployer as owner and first member
    constructor(){
        owner = msg.sender;
        isMember[latestVotingIndex][owner] = true;
        memberVotes[latestVotingIndex][owner] = Member(owner,0);
        members[latestVotingIndex].push(msg.sender);
        currentWinner[latestVotingIndex] = msg.sender;
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

    /// @notice Check if the voting ended
    modifier whenNotEnded(){
        require(block.timestamp>=endingTime[latestVotingIndex],"Voting Not Ended");
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
    function startVoting(uint _endTime) public onlyOwner{
        require(!isVotingStarted,"Voting Already Started. Wait For It To Stop");
        require(_endTime>600,"Minimum 10 Minutes Required To Start Voting");
        startTime[latestVotingIndex] = uint128(block.timestamp);
        endingTime[latestVotingIndex] = uint128(block.timestamp + (_endTime*1 days));
        isVotingStarted = true;
    }

    /// @notice Stops the voting process after end time
    /// @dev Only callable by owner and after voting period ends
    function stopVoting() public onlyOwner{
        require(isVotingStarted,"Not Started");
        require(block.timestamp>endingTime[latestVotingIndex],"Voting Is Not Ended");
        isVotingStarted = false;
    }

    /// @notice Adds a new member eligible for voting
    /// @dev Only owner can add members
    /// @param _user Address of the member to be added
    function makeMember(address _user) public onlyOwner{
        require(!isMember[latestVotingIndex][_user],"Already A Member");
        require(_user != address(0),"Invalid Address");
        isMember[latestVotingIndex][_user] = true;
        memberVotes[latestVotingIndex][_user] = Member(_user,0);
        members[latestVotingIndex].push(_user);
        emit MemberAdded(_user, uint128(block.timestamp));
    }

    /// @notice Allows a user to vote for a member
    /// @dev Each address can vote only once and only during active voting period
    /// @param _member Address of the member being voted for
    function vote(address _member) public whenNotPaused{
        require(isVotingStarted, "Voting not started");
        require(block.timestamp <= endingTime[latestVotingIndex], "Voting ended");
        require(isMember[latestVotingIndex][_member],"User Is Not A Member");
        require(!isVoted[latestVotingIndex][msg.sender],"Already Voted");
        Member storage m = memberVotes[latestVotingIndex][_member];
        totalVotes[latestVotingIndex]++;
        m.memberVotes++;
        isVoted[latestVotingIndex][msg.sender] = true;
        if(m.memberVotes>memberVotes[latestVotingIndex][currentWinner[latestVotingIndex]].memberVotes){
            secondHighestVotes[latestVotingIndex] = currentWinner[latestVotingIndex];
            currentWinner[latestVotingIndex] = _member;
        }else if(memberVotes[latestVotingIndex][_member].memberVotes==memberVotes[latestVotingIndex][currentWinner[latestVotingIndex]].memberVotes){
            secondHighestVotes[latestVotingIndex] = _member;
        }
        emit UserVoted(msg.sender, _member, uint128(block.timestamp));
    }


    /// @notice Allow Owner to start new voting
    function startNewVotingPeriod() public onlyOwner{
        require(!isVotingStarted,"Stop Current Voting First");
        isVotingStarted = false;
        isPaused = false;
        latestVotingIndex ++;
        isMember[latestVotingIndex][owner] = true;
        memberVotes[latestVotingIndex][owner] = Member(owner,0);
        members[latestVotingIndex].push(owner);
        currentWinner[latestVotingIndex] = owner;
    }


    /// @notice Returns the winning member
    /// @dev Should iterate through members and find highest votes
    /// @return winner The member with highest votes
    function getWinner() public view whenNotEnded returns(Member memory){
        require(members[latestVotingIndex].length>0,"No Members Participated");
        if(secondHighestVotes[latestVotingIndex] == address(0)) return memberVotes[latestVotingIndex][currentWinner[latestVotingIndex]];
        if(memberVotes[latestVotingIndex][secondHighestVotes[latestVotingIndex]].memberVotes==memberVotes[latestVotingIndex][currentWinner[latestVotingIndex]].memberVotes) revert("Tie Occured");
        return memberVotes[latestVotingIndex][currentWinner[latestVotingIndex]];
    }

    /// @notice Returns vote details of a specific member
    /// @param _user Address of the member
    /// @return Member struct containing address and vote count
    function viewVotes(address _user) public view returns(Member memory){
        require(isMember[latestVotingIndex][_user],"Not A Member");
        return memberVotes[latestVotingIndex][_user];
    }
}
