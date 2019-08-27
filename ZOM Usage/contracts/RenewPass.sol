pragma solidity ^0.5.0;

import "./SafeMath.sol"; 
import "./Ownable.sol";
import "./ERC20.sol";
import "./MedicalPass.sol";


contract RenewPass is Ownable   {
    
    MedicalPass public medicalContract;
    ERC20 public ZOM;
    
    
    uint256 public bronzePass = 500 * 10 ** 18;
    uint256 public silverPass = 1000* 10 ** 18;
    uint256 public goldPass = 2000* 10 ** 18;
    
    uint256 thirtyDaysToUnix=2592000;

     
    constructor (ERC20 _token) public {
        require(address(_token) != address(0), "token is the zero address");
        ZOM = _token;
        
    }


    function renewPass() public {
        uint256 index = medicalContract.getIndexByAddress(msg.sender);
        require(index !=0);
        if(compareStrings(medicalContract.getPassTypeByIndex(index),  "bronze")){
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >=bronzePass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             medicalContract.renewOrUpgrade(index , "bronze" , block.timestamp , block.timestamp+thirtyDaysToUnix);
             
        } else if(compareStrings(medicalContract.getPassTypeByIndex(index), "silver")){
            
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= silverPass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             medicalContract.renewOrUpgrade(index , "silver" , block.timestamp , block.timestamp+thirtyDaysToUnix);
             
        } else if(compareStrings(medicalContract.getPassTypeByIndex(index), "gold")){
            
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >=goldPass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             medicalContract.renewOrUpgrade(index , "gold" , block.timestamp , block.timestamp+thirtyDaysToUnix);

        } 

    }
    
       
    function compareStrings (string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
     }
    
}
