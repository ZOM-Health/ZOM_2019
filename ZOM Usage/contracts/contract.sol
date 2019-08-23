pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
    
contract MedicalPass is Ownable   {
    
    using SafeMath for uint256;
    
    struct Pass {
        uint256 hashId;
        string passType;
        address owner;
        uint256 issuedTimestamp;
        uint256 expiryTimestamp;
    }

    uint256 bronzePass = 500;
    uint256 silverPass = 1000;
    uint256 goldPass = 2000;
    
    uint256 thirtyDaysToUnix=2592000;
    
    
   
    Pass[] public issuedPasses;
    mapping(address => Pass) private lockCodeToIndex;



    constructor () public {
    
    }
    

      
}
