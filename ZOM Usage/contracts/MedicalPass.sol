pragma solidity ^0.5.0;

import "./SafeMath.sol"; 
import "./Ownable.sol";
import "./ERC20.sol";
    
contract MedicalPass is Ownable   {
    
    using SafeMath for uint256;
    ERC20 public ZOM;
    
    address public renewPassAddress;
     address public upgardePassAddress;


    
    struct Pass {
        string passType;
        address owner;
        uint256 issuedTimestamp;
        uint256 expiryTimestamp;
    }

    uint256 public bronzePass = 500 * 10 * 18;
    uint256 public silverPass = 1000* 10 * 18;
    uint256 public goldPass = 2000* 10 * 18;
    
    uint256 thirtyDaysToUnix=2592000;
    
   
    Pass[] public issuedPasses;
    mapping(address => uint256) public addressToPass;
    
    modifier onlyRenewPassOrUpgradePassOrOwner {
        require(msg.sender == renewPassAddress|| msg.sender == owner || msg.sender == upgardePassAddress);
        _;
    }

    
    constructor (ERC20 _token) public {
        require(address(_token) != address(0), "token is the zero address");
        ZOM = _token;
        
        Pass memory newPass = Pass("" , address(0) , 0 , 0);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }


    function buyBronzePass ()public {
        uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
        require(tokenAllowance >= bronzePass);
        ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
        
        Pass memory newPass = Pass("bronze" , msg.sender , block.timestamp , block.timestamp+thirtyDaysToUnix);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }
    
       function buySilverPass ()public {
        uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
        require(tokenAllowance >= silverPass);
        ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
        
        Pass memory newPass = Pass("silver" , msg.sender , block.timestamp , block.timestamp+thirtyDaysToUnix);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }
    
    
    function buyGoldPass ()public {
        uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
        require(tokenAllowance >= goldPass);
        ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
        
        Pass memory newPass = Pass("gold" , msg.sender , block.timestamp , block.timestamp+thirtyDaysToUnix);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }
    
    function compareStrings (string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
       }

    
      function setUpgradePassAddress(address _upgardePassAddress) public onlyOwner {
        upgardePassAddress = _upgardePassAddress;
    }
    
    function setRenewPassAddress(address _renewPassAddress) public onlyOwner {
        renewPassAddress = _renewPassAddress;
    }
    
    function renewOrUpgrade(uint256 index ,string memory _passType , uint256 _issuedTimestamp , uint256 _expiryTimestamp) public onlyRenewPassOrUpgradePassOrOwner {
          issuedPasses[index].passType = "goldPass";
             issuedPasses[index].issuedTimestamp = block.timestamp;
             issuedPasses[index].expiryTimestamp= block.timestamp + thirtyDaysToUnix;
    }
    
    function getIndexByAddress(address owner) public view returns(uint256){
        return addressToPass[owner];
    }
    
    function getPassTypeByIndex(uint256 index) public view returns(string memory){
        return issuedPasses[index].passType;
    }
    
      
}


