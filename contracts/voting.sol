// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Voting is ERC20 {

    //time variables
    uint startTime;
    uint _end;

    //determines whether or not certain functions get deactivated
    bool _isActive = true;

    address owner; //person who deployed the smart contract
    string[] public candidates; //names of candidates
    mapping(string => uint) public candidateVotesReceived; //mapping between candidate's names and the number of votes they've received.
    mapping(address => uint) public voterTokens; //mapping between a holder's(voter's) account and the number of tokens they have.


    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can commence or stop the voting process!");
        _;
    }

    modifier timeOver() {
        require(block.timestamp <= _end, "The time to vote is over or needs to be set again");
        _;
    }

    modifier checkActive() {
        require(_isActive, "Voting was closed by the owner");
        _;
    }


    constructor() ERC20("VoteToken", "VTN") { 
        owner = msg.sender;
        _mint(owner, 1000 * 10 ** 18);
    } 

    //start the time for voting
    function start() onlyOwner public {
        startTime = block.timestamp;
    }

    //set the amount of time until voting ends
    function end(uint totalTime) onlyOwner public {
        _end = totalTime + startTime;
    }

    //see the remaining time until voting ends
    function getRemainingTime() public timeOver view returns (uint) {
        return _end-block.timestamp;
    }

    

    //add the fives candidates to the array of candidates
    //only the owner can add the candidates
    function addCandidates() onlyOwner public {
        candidates = ['john', 'sara', 'luke', 'alex', 'olivia'];
    }

    //deposit wei for tokens
    //each time any amount of wei greater than zero is deposited, they receive one token
    function depositMoneyForToken() payable public checkActive timeOver {
        require(msg.value > 0, "value of wei can't be zero!");
        address from = msg.sender;
        giveToken(from);
    }

    //gets called from within depositMoneyForToken() function
    //the address in the voterTokens mapping gets a value of +1
    function giveToken(address senderAddress) private {
         voterTokens[senderAddress] += 1;
    }
    

    //add one to the candidate's number of votes as long as the voter has one or more tokens 
    //remove a token after the voter has voted
    function voteForCandidate(string memory candidate, address voterAddress) checkActive timeOver public {
        require(voterTokens[voterAddress] >= 1, "This voter doesn't have any tokens");
        candidateVotesReceived[candidate] += 1; //adds 1 vote for that person
        voterTokens[voterAddress] -= 1; //remove 1 token
    }

    
    //find how many votes each candidate got
    function votingResults(string memory candidate) view public returns(uint) {
        return candidateVotesReceived[candidate];
    }

  
    //disable or enable functions with the checkActive modifier
    function setActivity(bool isActive) onlyOwner public {
        _isActive = isActive;
    }
    
  
    
}